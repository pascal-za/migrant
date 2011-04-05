class <%= @activity.camelize.gsub(/\s/, '') %> < ActiveRecord::Migration
  def self.up
    create_table :<%= @table_name %> do |t|
      <%= @columns.join("\n      ") %>
    end
    <%= @indexes.join("\n    ") %>
  end
  
  def self.down
    drop_table :<%= @table_name %>
  end
end
