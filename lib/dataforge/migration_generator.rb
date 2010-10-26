module DataForge
  class MigrationGenerator
  
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
        model_schema = model.schema.columns
  
        if model.table_exists?
          db_schema = model.columns.collect {|c| [c.name.to_sym, Hash[*[:type].map { |type| [type, c.send(type)] }.flatten]  ] }
        else
          activity = "create_#{model.table_name}"          
          up_code = "create_table :#{model.table_name} do |t|"+NEWLINE+model_schema.collect do |name, options| 
            type = options.delete(:type)
            arguments = (options.blank?)? "" : ", #{options.inspect}"
            "t.#{type} :#{name}#{arguments}"
          end.join(NEWLINE)+"\nend"
          
          down_code = "drop_table :#{model.table_name}"
        end
        filename = "#{migrations_path}/#{next_migration_number}_#{activity}.rb"
        puts filename
        
      
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
      
      next_migration_number = current_migration_number + 1
      if ActiveRecord::Base.timestamped_migrations
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
      else
        "%.3d" % next_migration_number
      end
    end
  end
end
