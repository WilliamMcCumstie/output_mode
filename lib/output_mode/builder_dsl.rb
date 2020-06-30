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
  module BuilderDSL
    # The callable objects an `output` can be built from
    def output_callables
      @output_callables ||= Callables.new
    end

    # Adds a new callable object to {output_callables}
    # @abstract This maybe overridden to restrict the method signature
    # @param config Directly provided to {OutputMode::Callable#initialize}
    # @yield Directly provided to {OutputMode::Callable#initialize}
    def register_callable(**config, &b)
      output_callables << Callable.new(**config, &b)
    end

    # Sets and retrieves the builder block
    # @yieldparam *callables A duplicate of {output_callables}
    # @yieldparam **config The hash passed to the {build_output} method
    # @yieldreturn The block must return an instance of {OutputMode::Output}
    # @raise {OutputMode::Error} if the block is accesssed before being set
    # @return [Block] The builder block
    def output_builder(&b)
      @output_builder = b if b
      @output_builder || raise(OutputMode::Error, <<~ERROR)
        The 'output_builder' has not been set!
      ERROR
    end

    # Creates a new +output+ from the {output_builder} and provided +config+
    # @param config An arbitrary set of values to be passed to {output_builder}
    # @return OutputMode::Output The result of the block
    def build_output(**config)
      output_builder.call(*output_callables, **config)
    end
  end
end

