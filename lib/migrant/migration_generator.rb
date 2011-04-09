require 'erubis'

module Migrant
  class MigrationGenerator
    TABS = '  ' # Tabs to spaces * 2
    NEWLINE = "\n  "
    def run
      # Ensure db/migrate path exists before starting
      FileUtils.mkdir_p(Rails.root.join('db', 'migrate'))
 
      migrator = ActiveRecord::Migrator.new(:up, migrations_path)

      unless migrator.pending_migrations.blank?
        puts "You have some pending database migrations. You can either:\n1. Run them with rake db:migrate\n2. Delete them, in which case this task will probably recreate their actions (DON'T do this if they've been in SCM)."
        return false
      end

      # Get all tables and compare to the desired schema
      # The next line is an evil hack to recursively load all model files in app/models
      # This needs to be done because Rails normally lazy-loads these files, resulting a blank descendants list of AR::Base
      Dir["#{Rails.root.to_s}/app/models/**/*.rb"].each { |f| require(f) }

      ActiveRecord::Base.descendants.each do |model|
        next if model.schema.nil? || !model.schema.requires_migration? # Skips inherited schemas (such as models with STI)
        model.reset_column_information # db:migrate doesn't do this
        model_schema = model.schema.column_migrations
        @table_name = model.table_name

        if model.table_exists?
          # Structure ActiveRecord::Base's column information so we can compare it directly to the schema
          db_schema = Hash[*model.columns.collect {|c| [c.name.to_sym, Hash[*[:type, :limit].map { |type| [type, c.send(type)] }.flatten]  ] }.flatten]
            changes = model.schema.columns.collect do |name, data_type|
              begin
                [name, data_type.structure_changes_from(db_schema[name])]
              rescue DataType::DangerousMigration
                puts "Cannot generate migration automatically for #{model.table_name}, this would involve possible data loss on column: #{name}\nOld structure: #{db_schema[name].inspect}. New structure: #{data_type.column.inspect}\nPlease create and run this migration yourself (with the appropriate data integrity checks)"
                return false
              end
            end.reject { |change| change[1].nil? }
            next if changes.blank?
            @changed_columns, @added_columns = [], []
               
            # Fields to add/remove         
            changes.each do |field, options|
              if db_schema[field]
                @changed_columns << [field, options, db_schema[field]]
              else
                @added_columns << [field, options]
              end
            end

            # For adapters that can report indexes, add as necessary
            if ActiveRecord::Base.connection.respond_to?(:indexes)
              current_indexes = ActiveRecord::Base.connection.indexes(model.table_name).collect { |index| (index.columns.length == 1)? index.columns.first.to_sym : index.columns.collect(&:to_sym) }
              @indexes = model.schema.indexes.uniq.reject { |index| current_indexes.include?(index) }
            end

            # Example: changed_table_added_something_and_modified_something
            @activity = 'changed_'+model.table_name+[['added', @added_columns], ['modified', @changed_columns]].reject { |v| v[1].empty? }.collect { |v| "_#{v[0]}_"+v[1].collect(&:first).join('_') }.join('_and_')
            @activity = @activity.split('_')[0..2].join('_') if @activity.length >= 240 # Most filesystems will raise Errno::ENAMETOOLONG otherwise
            
            render('change_migration')
        else
          @activity = "create_#{model.table_name}"
          @columns = model_schema
          @indexes = model.schema.indexes
          
          render("create_migration")
        end
       
        filename = "#{migrations_path}/#{next_migration_number}_#{@activity}.rb"
        File.open(filename, 'w') { |migration| migration.write(@output) }
        puts "Wrote #{filename}..."
      end
      true
    end

    private
    def migrations_path
      Rails.root.join(ActiveRecord::Migrator.migrations_path)
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

