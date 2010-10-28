require 'active_support'
#require 'active_support/core_ext/class/attribute_accessors'
require 'active_record'
require 'datatype/base'
require 'migrant/schema'
require 'migrant/model_extensions'
require 'migrant/migration_generator'

module Migrant
  require 'railtie' if defined?(Rails)
  
  ActiveSupport.on_load :active_record do
    ActiveRecord::Base.extend(Migrant::ModelExtensions)
  end
end

