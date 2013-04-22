class <%= class_name %> < <%= parent_class_name.classify %>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
  structure do
<% unless attributes.blank?
     max_field_length = attributes.collect { |attribute| attribute.name.to_s}.max { |name| name.length }.length
     attributes.reject { |attr| attr.reference? }.each do |attribute| -%>
    <%= attribute.name.to_s.ljust(max_field_length) %> :<%= attribute.type %>
<%  end
   end -%>

    timestamps
  end
end

