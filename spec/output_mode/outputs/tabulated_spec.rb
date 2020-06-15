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

RSpec.describe OutputMode::Outputs::Tabulated do
  let(:procs) do
    [
      ->(v) { v.to_s },
      ->(v) { v.to_s.reverse },
      ->(_) { 'ignored' },
      ->(_) { nil },
      ->(_) { '' }
    ]
  end

  let(:data) { ['first', 'second', 'third'] }

  subject { described_class.new(*procs) }

  describe '#render' do
    it 'returns empty string' do
      expect(subject.render).to eq('')
    end

    context 'with basic data' do
      it 'returns the rendered data' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌──────┬──────┬───────┬┬┐
          │first │tsrif │ignored│││
          │second│dnoces│ignored│││
          │third │driht │ignored│││
          └──────┴──────┴───────┴┴┘
        TABLE
      end
    end

    context 'with headers' do
      let(:header) do
        ['stringify', 'reverse', 'ignore', 'nill', 'empty-string']
      end

      subject { described_class.new(*procs, header: header) }

      it 'returns the headers' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌─────────┬───────┬───────┬────┬────────────┐
          │stringify│reverse│ignore │nill│empty-string│
          ├─────────┼───────┼───────┼────┼────────────┤
          │first    │tsrif  │ignored│    │            │
          │second   │dnoces │ignored│    │            │
          │third    │driht  │ignored│    │            │
          └─────────┴───────┴───────┴────┴────────────┘
        TABLE
      end
    end
  end
end
