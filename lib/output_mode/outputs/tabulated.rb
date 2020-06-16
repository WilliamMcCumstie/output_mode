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

module OutputMode
  module Outputs
    class Tabulated < Base
      attr_reader :renderer, :header, :default, :block, :yes, :no

      # @!attribute [r] renderer
      #   @return [Symbol] the renderer type, see: https://github.com/piotrmurach/tty-table#32-renderer
      # @!attribute [r] header
      #   @return [Array] An optional header row for the table
      # @!attribute [r] default
      #   @return either a static default or a column based array of defaults
      # @!attribute [r] yes
      #   @return either a static yes value or a column based array of values
      # @!attribute [r] no
      #   @return either a static no value or a column based array of values
      # @!attribute [r] block
      #   @return [#call] an optional block of code that configures the renderer

      # @return [Hash] additional options to +TTY::Table+ renderer
      # @see https://github.com/piotrmurach/tty-table#33-options
      def config; super; end

      # @overload initialize(*procs, renderer: nil, header: nil, default: nil, **config)
      #   @param [Array] *procs see {OutputMode::Outputs::Base#initialize}
      #   @param [Symbol] :renderer override the default renderer
      #   @param [Array<String>] :header the header row of the table
      #   @param :default [String] replaces _blanks_ with a static string
      #   @param :default [Array] replace _blanks_ on a per column basis. The last value is repeated if the +procs+ are longer.
      #   @param :yes [String] replaces +true+ with a static string
      #   @param :yes [Array] replaces +true+ on a per column basis. The last value is repeated if the +procs+ are longer.
      #   @param :no [String] replaces +false+ with a static string
      #   @param :no [Array] replaces +false+ on a per column basis. The last value is repeated if the +procs+ are longer.
      #   @param [Hash] **config additional options to the renderer
      #   @yieldparam tty_table_renderer [TTY::Table::Renderer::Base] optional access the underlining TTY::Table renderer
      def initialize(*procs,
                     renderer: :unicode,
                     header: nil,
                     default: nil,
                     yes: nil,
                     no: nil,
                     **config,
                     &block)
        @header = header
        @renderer =  renderer
        @block = block
        @default = default
        @yes = yes
        @no = no
        super(*procs, **config)
      end

      # Implements the render method using +TTY::Table+
      # @see OutputMode::Outputs::Base#render
      # @see https://github.com/piotrmurach/tty-table
      def render(*data)
        table = TTY::Table.new header: header
        data.each do |datum|
          table << procs.each_with_index.map do |callable, idx|
            value = callable.call(datum)
            if [nil, ''].include? value
              index_selector(default, idx)
            elsif value == true
              index_selector(yes || 'true', idx)
            elsif value == false
              index_selector(no || 'false', idx)
            else
              value
            end
          end
        end
        table.render(renderer, **config, &block) || ''
      end

      private

      def index_selector(source, index)
        is_array = source.is_a? Array
        if is_array && source.length > index
          source[index]
        elsif is_array
          source.last
        else
          source
        end
      end
    end
  end
end

