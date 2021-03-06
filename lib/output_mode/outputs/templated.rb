#==============================================================================
# Copyright 2020 William McCumstie
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#==============================================================================

require 'pastel'

require 'output_mode/default_erb'

module OutputMode
  module Outputs
    class Templated < Output
      Entry = Struct.new(:output, :model, :colorize) do
        include Enumerable

        # @yieldparam value An attribute to be rendered
        # @yieldparam field: An optional field header for the value
        # @yieldparam padding: A padding string which will right align the +field+
        # @yieldparam **config TBA
        def each(section = nil)
          # Select the indices for the relevant section
          indices = (0...output.procs.length).to_a
          if section
            indices.select! do |idx|
              output.index_selector(:sections, idx) == section
            end
          end

          # Find the max field length
          max = indices.map do |idx|
            output.index_selector(:fields, idx).to_s.length
          end.max

          # Yield each selected attribute
          indices.each do |idx|
            value = generated[idx]
            field = output.index_selector(:fields, idx)
            padding = ' ' * (max - field.to_s.length)
            yield(value, field: field, padding: padding)
          end
        end

        # Renders an ERB object within the entry's context. This provides access to the
        # +output+, +model+, and +enumerable+ methods
        #
        # @param [ERB] erb the ERB object which contains the template to be rendered
        # @return [String] the result text
        def render(erb)
          erb.result(binding)
        end

        # Library for colorizing the output. It is automatically disabled when the
        # +colorize+ flag is +false+
        def pastel
          @pastel ||= Pastel.new(enabled: colorize)
        end

        private

        def generated
          @generated ||= output.generate(model)
        end
      end

      # @!attribute [r] erb
      #   @return [ERB] The +erb+ object containing the template to be rendered.
      # @!attribute [r] separator
      # @!attribute [r] fields
      # @!attribute [r] colorize
      # @!attribute [r] sections
      attr_reader :erb, :fields, :separator, :colorize, :sections

      # Create a new +output+ which will render using +ERB+. The provided +template+ should
      # only render the +output+ for a single +entry+ (aka model, record, data object, etc).
      #
      # The +template+ maybe either a +String+ or a +ERB+ object. Strings will automatically
      # be converted to +ERB+ with the +trim_mode+ set to +-+.
      #
      # A default template will be used if one has not be provided.
      #
      # @see https://ruby-doc.org/stdlib-2.7.1/libdoc/erb/rdoc/ERB.html
      # @see render
      # @see DEFAULT_ERB
      #
      # @overload initialize(*procs, template: nil, fields: nil, seperator: "\n", yes: 'true', no: 'false', **config)
      #   @param [Array] *procs see {OutputMode::Output#initialize}
      #   @param [ERB] template: The +template+ object used by the renderer
      #   @param [Array] fields: An optional array of field headers that map to the procs, repeating the last value if required
      #   @param fields: A static value to use as all field headers
      #   @param separator: The character(s) used to join the "entries" together
      #   @param colorize: Flags if the caller wants the colorized version, this maybe ignored by +template+
      #   @param sections: An optional array that groups the procs into sections. This is ignored by default
      #   @param [Hash] **config see {OutputMode::Output#initialize}
      def initialize(*procs,
                     template: nil,
                     fields: nil,
                     separator: "\n",
                     colorize: false,
                     sections: nil,
                     **config)
        @erb = case template
        when String
          ERB.new(template, nil, '-')
        when ERB
          template
        else
          DEFAULT_ERB
        end
        @fields = fields
        @separator = separator
        @colorize = colorize
        @sections = sections
        super(*procs, **config)
      end

      # Implements the render method using the ERB +template+. The +template+ will
      # be rendered within the context of an +Entry+. An +Entry+ object will be
      # created/ rendered for each element of +data+
      #
      # @see OutputMode::Output#render
      def render(*data)
        data.map { |d| Entry.new(self, d, colorize).render(erb) }
            .join(separator)
      end

      # Returns the length of the maximum field
      def max_field_length
        if fields.is_a? Array
          fields.map { |f| f.to_s.length }.max
        else
          fields.to_s.length
        end
      end
    end
  end
end

