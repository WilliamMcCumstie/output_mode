#==============================================================================
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
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
