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
  Mode = Struct.new(:type, :io) do
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
    # @param **config [Hash] Calls the `selector` with the config
    # @return [Boolean] The truthiness of the `selector` result or `false`
    # @see #selector
    def select?(**config)
      selector.call(**config) ? true : false
    end
  end
end

