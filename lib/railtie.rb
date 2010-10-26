# lib/my_gem/railtie.rb
require 'dataforge'
require 'rails'

module DataForge
  class Railtie < Rails::Railtie
    railtie_name :dataforge
  
    rake_tasks do
      load "tasks/db.rake"
    end
        
  end
end
