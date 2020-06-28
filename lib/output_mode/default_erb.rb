#==============================================================================
# Refer to README.md for licensing terms
#==============================================================================

require 'erb'

module OutputMode
  DEFAULT_ERB = ERB.new(<<~TEMPLATE, nil, '-')
    <% each do |value, field:, padding:, **_| -%>
    <%   if value.nil? && field.nil? -%>

    <%   elsif field.nil? -%>
     <%= pastel.green.bold '*' -%> <%= pastel.blue value %>
    <%   else -%>
    <%= padding -%><%= pastel.red.bold field -%><%= pastel.bold ':' -%> <%= pastel.blue value %>
    <%   end -%>
    <% end -%>
  TEMPLATE
end
