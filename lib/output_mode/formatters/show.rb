#==============================================================================
# Copyright 2021 William McCumstie
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

require 'output_mode/default_erb'
require 'output_mode/non_interactive_erb'

module OutputMode
  module Formatters
    class Show < Formatter
      include Enumerable

      # Limit the policy to a single object
      def initialize(object, **opts)
        super
      end

      def object
        @objects.first
      end

      def build_output
        bind = self.instance_exec { binding }
        OutputMode::Outputs::Templated.new(*callables, **attributes, bind: bind)
      end

      # @yieldparam value An attribute to be rendered
      # @yieldparam field: An optional field header for the value
      # @yieldparam padding: A padding string which will right align the +field+
      # @yieldparam **config TBA
      def each(section = nil, &block)
        # Select the callable objects
        selected = if section == nil
                     callables
                   elsif section == :default
                     callables.config_select(:section, :default, nil)
                   else
                     callables.config_select(:section, section)
                   end

        # Yield each selected attribute
        objs = selected.pad_each(object).map do |callable, padding:, field:|
          value = callable.call(object)
          [value, { field: field, padding: padding }]
        end

        # Runs the provided block
        objs.each(&block)
      end

      # Library for colorizing the output. It is automatically disabled when the
      # +colorize+ flag is +false+
      def pastel
        @pastel ||= Pastel.new(enabled: color?)
      end

      private

      def inbuilt_attributes
        additional = {}.tap do |hash|
          if interactive?
            hash[:template] = DEFAULT_ERB
          else
            hash[:template] = NON_INTERACTIVE_ERB
          end
        end
        super().merge(additional)
      end
    end
  end
end
