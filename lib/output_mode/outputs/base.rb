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
    # @abstract Defines the public interface to all subclasses
    #
    # Base outputting class that wraps an array of procs or other
    # callable object. Each implementation must override the {#render} method
    # so it returns an array.
    class Base
      # @!attribute [r] procs
      #   @return [Array<#call>] the callable methods to generate output
      # @!attribute [r] config
      #   @return [Hash] additional key-values to modify the render
      # @!attribute [r] default
      #   @return either a static default or a column based array of defaults
      # @!attribute [r] yes
      #   @return either a static yes value or a column based array of values
      # @!attribute [r] no
      #   @return either a static no value or a column based array of values
      attr_reader :procs, :config, :yes, :no, :default

      # Creates a new outputting instance from an array of procs
      #
      # @param *procs [Array<#call>] an array of procs (or callable objects)
      # @param default: [String] replaces _blanks_ with a static string
      # @param default: [Array] replace _blanks_ on a per column basis. The last value is repeated if the +procs+ are longer.
      # @param yes: [String] replaces +true+ with a static string
      # @param yes: [Array] replaces +true+ on a per column basis. The last value is repeated if the +procs+ are longer.
      # @param no: [String] replaces +false+ with a static string
      # @param no: [Array] replaces +false+ on a per column basis. The last value is repeated if the +procs+ are longer.
      # @param **config [Hash] a hash of additional keys to be stored
      def initialize(*procs, default: nil, yes: 'true', no: 'false', **config)
        @procs = procs
        @config = config
        @yes = yes
        @no = no
        @default = default
      end

      # Returns the results of the +procs+ for a particular +object+. It will apply the
      # +default+, +yes+, and +no+ values.
      def generate(object)
        procs.each_with_index.map do |p, idx|
          raw = p.call(object)
          if raw == true
            index_selector(:yes, idx)
          elsif raw == false
            index_selector(:no, idx)
          elsif !default.nil? && (raw.nil? || raw == '')
            index_selector(:default, idx)
          else
            raw
          end
        end
      end

      # @abstract It should be implemented by the subclass using the +generate+ method
      # Renders the results of the procs into a string. Each data
      # objects should be passed individual to each proc to generate the final
      # output.
      #
      # The method must be overridden on all inherited classes
      #
      # @param *data [Array] a set of data to be rendered into the output
      # @return [String] the output string
      # @see #generate
      def render(*data)
        raise NotImplementedError
      end

      # A helper method for selecting elements from a source array or return
      # a static value.
      #
      # @param [Symbol] method The source method on the +output+
      # @param [Integer] index The index to lookup
      #
      # @overload index_selector(array_method, valid_index)
      #   @param array_method A method that returns an array
      #   @param valid_index An index that is less than the array's length
      #   @return the value at the index
      #
      # @overload index_selector(array_method, out_of_bounds)
      #   @param array_method A method that returns an array
      #   @param out_of_bounds An index greater than the maximum array length
      #   @return the last element of the array
      #
      # @overload index_selector(non_array_method, _)
      #   @param non_array_method A method that does not return an array
      #   @param _ The index is ignored
      #   @return the result of the non_array_method
      def index_selector(method, index)
        source = public_send(method)
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
