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
      # @!attribute [r] headers
      #   @return [Array] An optional header row of the table
      # @!attribute [r] renderer
      #   @return [Symbol] select a renderer, see: https://github.com/piotrmurach/tty-table#32-renderer
      # @!attribute [r] render_opts
      #   @return [Hash] additional options to TTY:Table renderer, see: https://github.com/piotrmurach/tty-table#33-options
      attr_reader :headers
      attr_reader :renderer

      # @overload initialize(*procs, **config)
      #   @param [Array] *procs see {OutputMode::Outputs::Base#initialize}
      #   @option config [Array<String>] :header the header row of the table
      def initialize(*procs, **config)
        super
        @headers = config[:headers]
        @renderer =  config.fetch(:renderer, :unicode)
        @render_opts = config.fetch(:render_opts, {})
      end

      def render
        ''
      end
    end
  end
end

