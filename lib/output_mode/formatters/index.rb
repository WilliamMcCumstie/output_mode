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

module OutputMode
  module Formatters
    class Index < Formatter
      attr_reader :objects

      # Limit the policy to a single object
      def initialize(*objects, **opts)
        super
      end

      def build_output
        if interactive?
          Outputs::Tabulated.new(*callables, **attributes)
        else
          Outputs::Delimited.new(*callables, **attributes)
        end
      end

      private

      def inbuilt_attributes
        additional= {}.tap do |hash|
          # Handle unicode/ascii differences
          if interactive? && ascii?
            hash[:renderer] = :ascii
          elsif interactive?
            hash[:renderer] = :unicode
            hash[:header_color] = [:blue, :bold]
            hash[:row_color] = :green
          end

          # Additional tabulated/ delimited flags
          if interactive?
            hash[:rotate] = false
            hash[:padding] = [0, 1]
          else
            hash[:col_sep] ="\t"
          end
        end

        super().merge(additional)
      end
    end
  end
end
