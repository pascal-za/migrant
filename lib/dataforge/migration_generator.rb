module DataForge
  class MigrationGenerator
    def run
      # Get all tables and compare to the desired schema
      ActiveRecord::Base.descendants.each do |model|
        if model.table_exists?
          db_schema = model.columns.collect {|c| [c.name.to_sym, Hash[*[:type].map { |type| [type, c.send(type)] }.flatten]  ] }
        else
          db_schema = nil # Need to create table from scratch
        end
        
        model_schema = model.schema.column_migrations
      end
      false
    end
  end
end
