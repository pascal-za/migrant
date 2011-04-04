require 'active_support'
require 'active_record'
require 'dsl/data_type'
require 'migrant/schema'
require 'migrant/model_extensions'
require 'migrant/migration_generator'

module Migrant
  require 'railtie' if defined?(Rails)
  
  ActiveSupport.on_load :active_record do
    ActiveRecord::Base.extend(Migrant::ModelExtensions)
  end
end

