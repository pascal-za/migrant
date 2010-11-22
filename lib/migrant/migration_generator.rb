module Migrant
  class MigrationGenerator
    TABS = '  ' # Tabs to spaces * 2
    NEWLINE = "\n  "
    def run
      migrator = ActiveRecord::Migrator.new(:up, migrations_path)

      unless migrator.pending_migrations.blank?
        puts "You have some pending database migrations. You can either:\n1. Run them with rake db:migrate\n2. Delete them, in which case this task will probably recreate their actions (DON'T do this if they've been in SCM)."
        return false
      end
      
      # Get all tables and compare to the desired schema
      # The next line is an evil hack to recursively load all model files in app/models
      # This needs to be done because Rails normally lazy-loads these files, resulting a blank descendants list of AR::Base
      Dir["#{Rails.root.to_s}/app/models/**/*.rb"].each { |f| load(f) }

      ActiveRecord::Base.descendants.each do |model|
        next if model.schema.nil? || !model.schema.requires_migration? # Skips inherited schemas (such as models with STI)
        model.reset_column_information # db:migrate doesn't do this
        model_schema = model.schema.column_migrations
  
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
            activity = model.table_name+'_modify_fields_'+changes.collect { |field, options| field.to_s }.join('_')
            
            up_code = changes.collect do |field, options|
              type = options.delete(:type)            
              arguments = (options.blank?)? "" : ", #{options.inspect[1..-2]}"              
              
              if db_schema[field]
                "change_column :#{model.table_name}, :#{field}, :#{type}#{arguments}"
              else
                "add_column :#{model.table_name}, :#{field}, :#{type}#{arguments}"
              end
            end.join(NEWLINE+TABS)
           
            down_code = changes.collect do |field, options|
              if db_schema[field]
                type = db_schema[field].delete(:type)            
                arguments = (db_schema[field].blank?)? "" : ", #{db_schema[field].inspect[1..-2]}"              
                "change_column :#{model.table_name}, :#{field}, :#{type}#{arguments}"
              else
                "remove_column :#{model.table_name}, :#{field}"
              end
            end.join(NEWLINE+TABS)            
            
            # For adapters that can report indexes, add as necessary
            if ActiveRecord::Base.connection.respond_to?(:indexes)
              current_indexes = ActiveRecord::Base.connection.indexes(model.table_name).collect { |index| (index.columns.length == 1)? index.columns.first.to_sym : index.columns.collect(&:to_sym) }
              up_code += model.schema.indexes.uniq.collect do |index|
                unless current_indexes.include?(index)
                  NEWLINE+TABS+"add_index :#{model.table_name}, #{index.inspect}"
                end
              end.compact.join
            end
        else
          activity = "create_#{model.table_name}"          
          up_code = "create_table :#{model.table_name} do |t|"+NEWLINE+model_schema.collect do |field, options| 
            type = options.delete(:type)
            options.delete(:was) # Aliases not relevant when creating a new table
            arguments = (options.blank?)? "" : ", #{options.inspect[1..-2]}"
            (TABS*2)+"t.#{type} :#{field}#{arguments}"
          end.join(NEWLINE)+NEWLINE+TABS+"end"
          
          down_code = "drop_table :#{model.table_name}"
          up_code   += NEWLINE+TABS+model.schema.indexes.collect { |fields| "add_index :#{model.table_name}, #{fields.inspect}"}.join(NEWLINE+TABS)          
        end

        # Indexes
         # down_code += NEWLINE+TABS+model.schema.indexes.collect { |fields| "remove_index :#{model.table_name}, #{fields.inspect}"}.join(NEWLINE+TABS)
        filename = "#{migrations_path}/#{next_migration_number}_#{activity}.rb"
        File.open(filename, 'w') { |migration| migration.write(migration_template(activity, up_code, down_code)) }
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
    
    def migration_template(activity, up_code, down_code)
      "class #{activity.camelize.gsub(/\s/, '')} < ActiveRecord::Migration
  def self.up
    #{up_code}
  end
  
  def self.down
    #{down_code}
  end
end"
    end
  end
end
