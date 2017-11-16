class <%= @activity.camelize.gsub(/\s/, '') %> < ActiveRecord::Migration
  def self.up
    create_table :<%= @table_name %> do |t|
      <% @columns.each do |field, options| %>
      t.<%= options.delete(:type) %> :<%= field %><%= (options.blank?)? '': ", "+options.inspect[1..-2] %>
      <% end %>
    end
    <% @indexes.each do |index, options| %>
    add_index :<%= @table_name %>, <%= index.inspect %>
    <% end -%>
  end

  def self.down
    drop_table :<%= @table_name %>
  end
end
