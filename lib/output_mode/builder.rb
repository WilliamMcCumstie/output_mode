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
  class Builder
    attr_reader :callables, :config

    # Create a new +Builder+ object that can generate an +Output+
    # @overload initialize(*callables, **config)
    #   @param [Array<OutputMode::Callable>] *callables A grand list of all possible callables
    #   @param [Hash] **config An arbitrary hash of configuration values
    def initialize(*callables, **config)
      @callables ||= callables
      @config ||= config
    end

    # Define which output class to create
    # @abstract Must be overridden by inherited class
    # @return [Class] an inherited class off {OutputMode::Output}
    def output_class
      raise NotImplementedError
    end

    # The options hash provided to the {output_class} +initialize~
    # NOTE: The +output_options+ are unrelated to +config+. Passing values
    # from +config+ to +output_options+ needs to be done manually on a per
    # implementation basis.
    # @abstract Maybe overridden to provide additional options
    # @return [Hash] the options hash
    def output_options
      {}
    end

    # The +IO+ that the output will be used with. Whilst not strictly required,
    # a singular +IO+ should be used for consistency. Defaults to +$stdout+
    # @abstract Maybe overridden by the inherited class
    def output_io
      $stdout
    end

    # The {OutputMode::Callable} objects provided to the +output+. By default this
    # wraps {callables}.
    # @abstract Maybe overridden to provide filtering of +callables+
    def output_callables
      callables
    end

    # A block to be provided to the +output+
    # @abstract Maybe overridden by the inherited class
    def output_block
    end

    # Returns the newly constructed +output+
    # @return [OutputMode::Output]
    def output
      output_class.new(*output_callables, **output_options, &output_block)
    end
  end
end

