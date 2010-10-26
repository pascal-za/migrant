module DataForge
  class MigrationGenerator
    def initialize
      @migration_increment = 1
    end
  
    TABS = '  ' # Tabs to spaces * 2
    NEWLINE = "\n  "
    def run
      migrator = ActiveRecord::Migrator.new(:up, migrations_path)

      unless migrator.pending_migrations.blank?
        puts "You have some pending database migrations. Either run db:migrate to apply them, or physically remove them to have them combined into one migration by this task (ONLY if other developers haven't run them!)."
        return false
      end

      # Get all tables and compare to the desired schema
      ActiveRecord::Base.descendants.each do |model|
        next if model.schema.nil? || !model.schema.requires_migration? # Skips inherited schemas (such as models with STI)
        model_schema = model.schema.columns
  
        if model.table_exists?
          db_schema = model.columns.collect {|c| [c.name.to_sym, Hash[*[:type].map { |type| [type, c.send(type)] }.flatten]  ] }
        else
          activity = "create_#{model.table_name}"          
          up_code = "create_table :#{model.table_name} do |t|"+NEWLINE+model_schema.collect do |name, options| 
            type = options.delete(:type)
            options.delete(:was) # Aliases not relevant when creating a new table
            arguments = (options.blank?)? "" : ", #{options.inspect[1..-2]}"
            (TABS*2)+"t.#{type} :#{name}#{arguments}"
          end.join(NEWLINE)+NEWLINE+TABS+"end"
          
          down_code = "drop_table :#{model.table_name}"
          up_code   += NEWLINE+TABS+model.schema.indexes.collect { |fields| "add_index :#{model.table_name}, #{fields.inspect}"}.join(NEWLINE+TABS)          
        end

        # Indexes
         # down_code += NEWLINE+TABS+model.schema.indexes.collect { |fields| "remove_index :#{model.table_name}, #{fields.inspect}"}.join(NEWLINE+TABS)
        filename = "#{migrations_path}/#{next_migration_number}_#{activity}.rb"
        if File.exists?(filename)
          raise RuntimeError, "The migration #{filename} already exists. This shouldn't happen, try removing the migration and try again."
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
    def next_migration_number #:nodoc:
      current_migration_number = Dir.glob(Rails.root.join(migrations_path+"/[0-9]*_*.rb")).collect do |file|
        File.basename(file).split("_").first.to_i
      end.max.to_i

      @migration_increment += 1      
      next_migration_number = current_migration_number + @migration_increment
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S").to_s.to_i+@migration_increment
      else
        next_migration_number
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
