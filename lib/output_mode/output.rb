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
  # @abstract Defines the public interface to all subclasses
  #
  # Base outputting class that wraps an array of procs or other
  # callable object. Each implementation must override the {#render} method
  # so it returns an array.
  class Output
    # @!attribute [r] procs
    #   @return [Array<#call>] the callable methods to generate output
    # @!attribute [r] config
    #   @return [Hash] additional key-values to modify the render
    # @!attribute [r] default
    #   @return either a static default
    # @!attribute [r] yes
    #   @return either a static yes value
    # @!attribute [r] no
    #   @return either a static no value
    # @!attribute [r] context
    #   @return a hash of keys to be provided to the callables
    attr_reader :procs, :config, :yes, :no, :default, :context

    # Creates a new outputting instance from an array of procs
    #
    # @param *procs [Array<#call>] an array of procs (or callable objects)
    # @param default: [String] replaces _blanks_ with a static string
    # @param yes: [String] replaces +true+ with a static string
    # @param no: [String] replaces +false+ with a static string
    # @param context: [Hash] of keys to be provided to the callables
    # @param **config [Hash] a hash of additional keys to be stored
    def initialize(*procs, default: nil, yes: 'true', no: 'false', context: {}, **config)
      @procs = Callables.new(procs)
      @config = config
      @yes = yes
      @no = no
      @default = default
      @context = context
    end

    def callables
      procs
    end

    # Returns the results of the +procs+ for a particular +object+. It will apply the
    # +default+, +yes+, and +no+ values.
    def generate(object)
      procs.map do |callable|
        callable.generator(self).call(object)
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
  end
end
