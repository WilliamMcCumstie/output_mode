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

RSpec.describe OutputMode::Outputs::Delimited do
  let(:procs) do
    [
      ->(v) { v.to_s },
      ->(v) { v.to_s.reverse },
      ->(_) { 'ignored' },
      ->(_) { nil },
      ->(_) { '' },
      ->(_) { true },
      ->(_) { false }
    ]
  end

  let(:data) { ['first', 'second', 'third'] }

  subject { described_class.new(*procs) }

  describe '#render' do
    it 'returns empty string' do
      expect(subject.render).to eq('')
    end

    context 'with basic data' do
      subject { described_class.new(*procs) }

      it 'returns the rendered data' do
        expect(subject.render(*data)).to eq(<<~TABLE)
          first,tsrif,ignored,,,true,false
          second,dnoces,ignored,,,true,false
          third,driht,ignored,,,true,false
        TABLE
      end

      it 'uses the generate method' do
        data.each do |datum|
          expect(subject).to receive(:generate).with(datum).and_call_original
        end
        subject.render(*data)
      end
    end

    context 'with a custom separator' do
      let(:col_sep) { '*' }
      let(:row_sep) { "\r" }

      let(:custom_data) { ['demo', col_sep, row_sep] }

      subject do
        described_class.new(*procs, col_sep: col_sep, row_sep: row_sep)
      end

      it 'passes the options through' do
        expect(subject.render(*custom_data)).to eq([
          'demo*omed*ignored***true*false',
          '"*"*"*"*ignored***true*false',
          # The " are literal characters within the heredoc
          <<~'RENDERED_ROW_SEP'.chomp,
            \r*\r*ignored***true*false
          RENDERED_ROW_SEP
          '' # Ends with additional row_sep
        ].join("\r"))
      end
    end
  end
end
