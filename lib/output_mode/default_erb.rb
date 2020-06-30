#==============================================================================
# Refer to LICENSE.txt for licensing terms
#==============================================================================

require 'erb'

module OutputMode
  DEFAULT_ERB = ERB.new(<<~TEMPLATE, nil, '-')
    <% each do |value, field:, padding:, **_| -%>
    <%   if value.nil? && field.nil? -%>

    <%   elsif field.nil? -%>
     <%= pastel.bold '*' -%> <%= pastel.green value %>
    <%   else -%>
    <%= padding -%><%= pastel.blue.bold field -%><%= pastel.bold ':' -%> <%= pastel.green value %>
    <%   end -%>
    <% end -%>
  TEMPLATE
end
