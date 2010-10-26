require 'active_support'
#require 'active_support/core_ext/class/attribute_accessors'
require 'active_record'
require 'datatype/base'
require 'dataforge/schema'
require 'dataforge/model_extensions'
require 'dataforge/migration_generator'

module DataForge
  require 'railtie' if defined?(Rails)
  
  ActiveSupport.on_load :active_record do
    ActiveRecord::Base.extend(DataForge::ModelExtensions)
  end
end

