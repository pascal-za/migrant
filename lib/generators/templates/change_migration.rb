class <%= @activity.camelize.gsub(/\s/, '') %> < ActiveRecord::Migration
  def self.up
    <%= @up_steps.join("\n    ") %>
  end
  
  def self.down
    <%= @down_steps.join("\n    ") %>
  end
end
