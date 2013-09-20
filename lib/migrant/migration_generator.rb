require 'erubis'
require 'term/ansicolor'

module Migrant
  class MigrationGenerator
    def run
      # Ensure db/migrate path exists before starting
      FileUtils.mkdir_p(Rails.root.join('db', 'migrate'))
      @possible_irreversible_migrations = false

      migrator = (ActiveRecord::Migrator.public_methods.include?(:open))? 
                  ActiveRecord::Migrator.open(migrations_path) : 
                  ActiveRecord::Migrator.new(:up, migrations_path)

      unless migrator.pending_migrations.blank?
        log "You have some pending database migrations. You can either:\n1. Run them with rake db:migrate\n2. Delete them, in which case this task will probably recreate their actions (DON'T do this if they've been in SCM).", :error
        return false
      end

      # Get all tables and compare to the desired schema
      # The next line is an evil hack to recursively load all model files in app/models
      # This needs to be done because Rails normally lazy-loads these files, resulting a blank descendants list of AR::Base
      model_root = "#{Rails.root.to_s}/app/models/"

      Dir["#{model_root}**/*.rb"].each do |file|
        if (model_name = file.sub(model_root, '').match(/(.*)?\.rb$/))
          model_name[1].camelize.safe_constantize
        end
      end

      # Rails 3.2+ caches table (non) existence so this needs to be cleared before we start
      ActiveRecord::Base.connection.schema_cache.clear! if ActiveRecord::Base.connection.respond_to?(:schema_cache)

      ActiveRecord::Base.descendants.select { |model| model.structure_defined? && model.schema.requires_migration? }.each do |model|
        model.reset_column_information # db:migrate doesn't do this
        @table_name = model.table_name
        @columns = Hash[[:changed, :added, :deleted, :renamed, :transferred].collect { |a| [a,[]] }]

        if model.table_exists?
          # Structure ActiveRecord::Base's column information so we can compare it directly to the schema
          db_schema = Hash[*model.columns.collect {|c| [c.name.to_sym, Hash[*[:type, :limit, :default].map { |type| [type, c.send(type)] }.flatten]  ] }.flatten]
          model.schema.columns.to_a.sort { |a,b| a.to_s <=> b.to_s }.each do |field_name, data_type|
            if data_type.dangerous_migration_from?(db_schema[field_name]) &&
               ask_user("#{model}: '#{field_name}': Converting from ActiveRecord type #{db_schema[field_name][:type]} to #{data_type.column[:type]} could cause data loss. Continue?", %W{Yes No}, true) == "No"
              log "Aborting dangerous action on #{field_name}."
            elsif (options = data_type.structure_changes_from(db_schema[field_name]))
              if db_schema[field_name]
                change_column(field_name, options, db_schema[field_name])
              else
                add_column(field_name, options)
              end
            end
          end

          # Removed rows
          unless model.schema.partial?
            db_schema.reject { |field_name, options| field_name.to_s == model.primary_key || model.schema.columns.keys.include?(field_name) }.each do |removed_field_name, options|
              case ask_user("#{model}: '#{removed_field_name}' is no longer in use.", (@columns[:added].blank?)? %W{Destroy Ignore} : %W{Destroy Move Ignore})
                when 'Destroy' then delete_column(removed_field_name, db_schema[removed_field_name])
                when 'Move' then
                  target = ask_user("Move '#{removed_field_name}' to:", @columns[:added].collect(&:first))
                  target_column = model.schema.columns[target]

                  unless target_column.dangerous_migration_from?(db_schema[removed_field_name])
                    target_column.structure_changes_from(db_schema[removed_field_name])
                    move_column(removed_field_name, target, db_schema[removed_field_name], target_column)
                  else
                    case ask_user("Unable to safely move '#{removed_field_name}' to '#{target}'. Keep the original column for now?", %W{Yes No}, true)
                      when 'No' then delete_column(removed_field_name, db_schema[removed_field_name])
                    end
                  end
              end
            end
          end
          destroyed_columns = @columns[:deleted].reject { |field, options| @columns[:transferred].collect(&:first).include?(field) }
          unless destroyed_columns.blank?
            if ask_user("#{model}: '#{destroyed_columns.collect(&:first).join(', ')}' and associated data will be DESTROYED in all environments. Continue?", %W{Yes No}, true) == 'No'
              log "Okay, not removing anything for now."
              @columns[:deleted] = []
            end
          end

          # For adapters that can report indexes, add as necessary
          if ActiveRecord::Base.connection.respond_to?(:indexes)
            current_indexes = ActiveRecord::Base.connection.indexes(model.table_name).collect { |index| (index.columns.length == 1)? index.columns.first.to_sym : index.columns.collect(&:to_sym) }
            @indexes = model.schema.indexes.uniq.reject { |index| current_indexes.include?(index) }.collect do |field_name|
              description = (field_name.respond_to?(:join))? field_name.join('_') : field_name.to_s

              [field_name, description]
            end

            # Don't spam the user with indexes that columns are being created with
            @new_indexes = @indexes.reject { |index, options| @columns[:changed].detect { |c| c.first == index } || @columns[:added].detect { |c| c.first == index } }
          end

          next if @columns[:changed].empty? && @columns[:added].empty? && @columns[:renamed].empty? && @columns[:transferred].empty? && @columns[:deleted].empty? && @indexes.empty? # Nothing to do for this table

          # Example: changed_table_added_something_and_modified_something
          @activity = 'changed_'+model.table_name+[['added', @columns[:added]], ['modified', @columns[:changed]], ['deleted', destroyed_columns],
          ['moved', @columns[:transferred]], ['renamed', @columns[:renamed]], ['indexed', @new_indexes]].reject { |v| v[1].empty? }.collect { |v| "_#{v[0]}_"+v[1].collect(&:last).join('_') }.join('_and')
          @activity = @activity.split('_')[0..2].join('_')+'_with_multiple_changes' if @activity.length >= 240 # Most filesystems will raise Errno::ENAMETOOLONG otherwise

          render('change_migration')
        else
          @activity = "create_#{model.table_name}"
          @columns = model.schema.column_migrations
          @indexes = model.schema.indexes.uniq

          render("create_migration")
        end

        filename = "#{migrations_path}/#{next_migration_number}_#{@activity}.rb"
        File.open(filename, 'w') { |migration| migration.write(@output) }
        log "Wrote #{filename}..."
      end

      if @possible_irreversible_migrations
        log "*** One or more move operations were performed, which potentially could cause data loss on db:rollback. \n*** Please review your migrations before committing!", :warning
      end

      true
    end

    private
    def add_column(name, options)
      @columns[:added] << [name, options, name]
    end

    def change_column(name, new_schema, old_schema)
      if new_schema[:default] && new_schema[:default].respond_to?(:to_s) && new_schema[:default].to_s.length < 31
        change_description = "#{name}_defaulted_to_#{new_schema[:default].to_s.underscore}"
      else
        change_description = name
      end

      @columns[:changed] << [name, new_schema, old_schema, change_description]
    end

    def delete_column(name, current_structure)
      @columns[:deleted] << [name, current_structure, name]
    end

    def move_column(old_name, new_name, old_schema, new_schema)
      if new_schema == old_schema
        @columns[:renamed] << [old_name, new_name, old_name]
        @columns[:added].reject! { |a| a.first == new_name } # Don't add the column too
      else
        @possible_irreversible_migrations = true
        @columns[:transferred] << [old_name, new_name, old_name] # Still need to add the column, just transfer the data afterwards
        delete_column(old_name, old_schema)
      end
    end

    def migrations_path
      Rails.root.join(ActiveRecord::Migrator.migrations_path)
    end

    include Term::ANSIColor
    def ask_user(message, choices, warning=false)
      mappings = choices.uniq.inject({}) do |mappings, choice|
        choice_string = choice.to_s
        choice_string.length.times do |i|
          mappings.merge!(choice_string[i..i] => choice) and break unless mappings.keys.include?(choice_string[i..i])
        end
        mappings.merge!(choice_string => choice) unless mappings.values.include?(choice)
        mappings
      end

      begin
        prompt = "> #{message} [#{mappings.collect { |shortcut, choice| choice.to_s.sub(shortcut, '('+shortcut+')') }.join(' / ')}]: "
        if warning
          STDOUT.print red, bold, prompt, reset
        else
          STDOUT.print bold, prompt, reset
        end
        STDOUT.flush
        input = STDIN.gets.downcase
      end until (choice = mappings.detect { |shortcut, choice| [shortcut.downcase,choice.to_s.downcase].include?(input.downcase.strip) })
      choice.last
    end

    def log(message, type=:info)
      STDOUT.puts(
        case type
          when :error
            [red, bold, message, reset]
          when :warning
            [yellow, message, reset]
          else
            message
        end
      )
    end
    # See ActiveRecord::Generators::Migration
    # Only generating a migration to each second is a problem.. because we generate everything in the same second
    # So we have to add further "pretend" seconds. This WILL cause problems.
    # TODO: Patch ActiveRecord to end this nonsense.
    def next_migration_number #:nodoc:
      highest = Dir.glob(migrations_path.to_s+"/[0-9]*_*.rb").collect do |file|
        File.basename(file).split("_").first.to_i
      end.max

      if ActiveRecord::Base.timestamped_migrations
        base = Time.now.utc.strftime("%Y%m%d%H%M%S").to_s
        (highest.to_i >= base.to_i)? (highest + 1).to_s : base
      else
        (highest.to_i + 1).to_s
      end
    end

    def render(template_name)
      @output = Erubis::Eruby.new(File.read(File.join(File.dirname(__FILE__), "../generators/templates/#{template_name}.erb"))).result(binding)
    end
  end
end

