module DataForge
  class MigrationGenerator
    def initialize
      @migration_increment = 1
    end
  
    TABS = '  ' # Tabs to spaces * 2
    NEWLINE = "\n  "
    def run(ignore_pending_migrations=false)
      migrator = ActiveRecord::Migrator.new(:up, migrations_path)

      unless migrator.pending_migrations.blank? || ignore_pending_migrations
        puts "You have some pending database migrations. Either run db:migrate to apply them, or physically remove them to have them combined into one migration by this task (ONLY if other developers haven't run them!)."
        return false
      end

      # Get all tables and compare to the desired schema
      ActiveRecord::Base.descendants.each do |model|
        next if model.schema.nil? || !model.schema.requires_migration? # Skips inherited schemas (such as models with STI)
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
            activity = model.table_name+'_modify_fields_'+changes.collect { |field, options| field.to_s }.join('_')
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

        if File.exists?(filename)
          puts "The migration #{filename} already exists. This shouldn't happen, try removing the migration and try again."
          return false
        end
        File.open(filename, 'w') { |migration| migration.write(migration_template(activity, up_code, down_code)) }
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
        (highest + 1).to_s
      end
    end
    
    def migration_template(activity, up_code, down_code)
      "class #{activity.titleize.gsub(/\s/, '')} < ActiveRecord::Migration
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
