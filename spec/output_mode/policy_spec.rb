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

require 'spec_helper'

RSpec.describe OutputMode::Policy do
  [true, false, nil].repeated_permutation(3).each do |bools|
    interactive = bools[0]
    ascii = bools[1]
    verbose = bools[2]

    interactive_str = interactive.nil? ? 'nil' : interactive.to_s
    ascii_str = ascii.nil? ? 'nil' : ascii.to_s
    verbose_str = verbose.nil? ? 'nil' : verbose.to_s

    msg = "when interactive is #{interactive_str}, ascii  is #{ascii_str}, and verbose is #{verbose_str}"
    context(msg) do
      subject { described_class.new(interactive: interactive, verbose: verbose, ascii: ascii) }

      it { is_expected.send(interactive ? :to : :not_to, be_interactive) } unless interactive.nil?
      it { is_expected.send(ascii ? :to : :not_to, be_ascii) } unless ascii.nil?
      it { is_expected.send(verbose ? :to : :not_to, be_verbose) } unless verbose.nil?
    end
  end
end
