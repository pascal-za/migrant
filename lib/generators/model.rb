require 'rails/generators/active_record'

module Migrant
  class Model < ActiveRecord::Generators::Base
    argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
    desc "The migrant:model generator creates a skeleton ActiveRecord model for use with Migrant."
    source_root File.expand_path("../templates", __FILE__)
    
    def create_model_file
      template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
    end
    
    hook_for :test_framework
    
    def protip
      puts "\nNow, go and edit app/models/#{file_name}.rb and/or generate more models, then run 'rake db:upgrade' to generate your schema."
    end

    protected
    def parent_class_name
      options[:parent] || "ActiveRecord::Base"
    end
  end
end
