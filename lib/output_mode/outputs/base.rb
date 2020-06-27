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
      attr_reader :procs, :config

      # Creates a new outputting instance from an array of procs
      #
      # @param *procs [Array<#call>] an array of procs (or callable objects)
      # @param **config [Hash] a hash of additional keys to be stored
      def initialize(*procs, **config)
        @procs = procs
        @config = config
      end

      # @abstract It must be implemented by the subclass
      # Renders the results of the procs into a string. Each data
      # objects should be passed individual to each proc to generate the final
      # output.
      #
      # The method must be overridden on all inherited classes
      #
      # @param *data [Array] a set of data to be rendered into the output
      # @return [String] the output string
      def render(*data)
        raise NotImplementedError
      end

      # A method for selecting an element from an array or static value
      # @overload index_selector(array_source, valid_index)
      #   @return the array's value at the index
      # @overload index_selector(array_source, index_larger_than_source)
      #   @return the last value of the array
      # @overload index_selector(non_array_source, _)
      #   @return the non_array_source
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
