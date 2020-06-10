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
  Mode = Struct.new(:type) do
    # Defines the selection proc when called with a `block`.
    # Returns the previously defined `block` when called without any inputs.
    # Returns a block that returns false when a block has not been
    # previously set.
    #
    # NOTE: This method does not execute the block. Instead it will be ran by
    # the `select?` method with the corresponding `config`.
    #
    # @yield Determines the truthiness of the select? method
    # @yieldparam **config [Hash] Arbitrary key-value pairs
    # @see #select?
    def selector(&block)
      @selector = block if block_given?
      @selector || -> { false }
    end

    # Returns if the mode should be selected by the renderer. This method will
    # run the custom selector block and returns the result based on the
    # truthiness. It will default to `false` if no `selector` is available.
    #
    # The `config` will be passed to the `selector` in order to modify the
    # selection based on external inputs.
    #
    # @param **config [Hash] Calls the `selector` with this hash
    # @return [Boolean] The truthiness of the `selector` result or `false`
    # @see #selector
    def select?(**config)
      selector.call(**config) ? true : false
    end

    # Define a output proc when called with a block. Returns the previously
    # defined proc when called without a block. Returns Nil when there is
    # no previously defined block.
    #
    # The block must return the text that will ultimately be outputted to
    # StandardOut (or other IO). It must not write to the IO directly as
    # this is handled by the renderer.
    #
    # The block will be given a 2D array of data which needs to be rendered.
    # Each sub-array is intended to be a row of data, however it maybe render
    # as a column.
    #
    # The block will also be provided with a optional config. This config
    # may contain additional fields to be rendered (e.g. headers, keys, etc.)
    #
    # NOTE: This method does not execute the block.
    # @yield The result will be printed to the output IO
    # @yieldparam *data [Array<Array>] A 2D array of table data
    # @yieldparam **config [Hash] Arbitrary key-value pairs
    def outputer(&block)
      @outputer = block if block_given?
      @outputer
    end

    # Generates a formatted string for the input data.
    #
    # The actual outputting is done by the outputer proc. The data must be
    # a 2D array to be rendered. The config may contain arbitrary pairs.
    #
    # @param *data, [Array<Array>] A 2D array of data to be rendered
    # @param **config [Hash] Arbitrary key value pairs
    def output(*data, **config)
      outputer&.call(*data, **config) || ''
    end
  end
end

