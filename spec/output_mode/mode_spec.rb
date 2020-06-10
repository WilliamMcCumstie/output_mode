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

RSpec.describe OutputMode::Mode do
  subject { described_class.new(:subject) }

  describe '#select?' do
    it 'returns false' do
      expect(subject.select?).to be_falsey
    end

    describe '#selector' do
      it 'returns true based on the blocks truthiness' do
        subject.selector { 'some truthy value' }
        expect(subject.select?).to be true
      end

      it 'can use config values in the block' do
        subject.selector { |**c| c[:key] }
        expect(subject.select?(key: true)).to be true
      end
    end
  end

  describe '#output' do
    it 'returns empty string by default' do
      expect(subject.output([])).to eq('')
    end

    describe '#outputer' do
      it 'renders the data to a string' do
        data = [['value1', 'value2'], ['data1', 'data2']]
        block = ->(d) { d.map { |v| v.join('-') }.join("\n") }
        str = block.call(data)
        subject.outputer(&block)
        expect(subject.output(data)).to eq(str)
      end
    end
  end
end

