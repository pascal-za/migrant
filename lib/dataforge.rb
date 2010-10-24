require 'datatype/base'
require 'dataforge/schema'
require 'dataforge/model_extensions'

module DataForge
  require 'railtie' if defined?(Rails)
  
  ActiveSupport.on_load :active_record do
    ActiveRecord::Base.extend(DataForge::ModelExtensions)
  end
end

