require 'rails/generators'

class Migrations < Rails::Generators::Base
  def migrate
    Migrant::MigrationGenerator.new.run
  end
end
