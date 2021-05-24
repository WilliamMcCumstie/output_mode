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

  let(:procs_with_bools) do
    procs.dup.tap do |p|
      p << ->(_) { true }
      p << ->(_) { false }
    end
  end

  let(:data) { ['first', 'second', 'third'] }

  subject { described_class.new(*procs) }

  describe '#render' do
    it 'returns empty string' do
      expect(subject.render).to eq('')
    end

    context 'with basic data' do
    subject { described_class.new(*procs_with_bools) }

      it 'returns the rendered data' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌──────┬──────┬───────┬┬┬────┬─────┐
          │first │tsrif │ignored│││true│false│
          │second│dnoces│ignored│││true│false│
          │third │driht │ignored│││true│false│
          └──────┴──────┴───────┴┴┴────┴─────┘
        TABLE
      end
    end

    context 'with headers' do
      let(:header) do
        ['stringify', 'reverse', 'ignore', 'nill', 'empty-string']
      end

      subject { described_class.new(*procs) }

      before do
        subject.callables.each_with_index { |c, idx| c.config[:header] = header[idx] }
      end

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

    context 'with colorized headers and data' do
      let(:header) do
        ['stringify', 'reverse', 'ignore', 'nill', 'empty-string']
      end

      subject do
        described_class.new(*procs, header: header, header_color: [:blue, :bold], row_color: :yellow, colorize: true)
      end

      before do
        subject.callables.each_with_index do |callable, idx|
          callable.config[:row_color] = :green if idx == 0
          callable.config[:header] = header[idx]
        end
      end

      it 'colorizes the headers and rows' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌─────────┬───────┬───────┬────┬────────────┐
          │\e[34;1mstringify\e[0m│\e[34;1mreverse\e[0m│\e[34;1mignore\e[0m │\e[34;1mnill\e[0m│\e[34;1mempty-string\e[0m│
          ├─────────┼───────┼───────┼────┼────────────┤
          │\e[32mfirst\e[0m    │\e[33mtsrif\e[0m  │\e[33mignored\e[0m│    │            │
          │\e[32msecond\e[0m   │\e[33mdnoces\e[0m │\e[33mignored\e[0m│    │            │
          │\e[32mthird\e[0m    │\e[33mdriht\e[0m  │\e[33mignored\e[0m│    │            │
          └─────────┴───────┴───────┴────┴────────────┘
        TABLE
      end
    end

    context 'with colorization explicitly turned off' do
      let(:header) do
        ['stringify', 'reverse', 'ignore', 'nill', 'empty-string']
      end

      subject do
        described_class.new(*procs, header: header, header_color: [:blue, :bold], row_color: [:green], colorize: false)
      end

      before do
        subject.callables.each_with_index { |c, idx| c.config[:header] = header[idx] }
      end

      it 'does not colorize' do
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

    context 'with render options' do
      let(:opts) { { alignments: ['right', 'left', 'right'] } }

      subject { described_class.new(*procs, **opts) }

      it 'applies the options' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌──────┬──────┬───────┬┬┐
          │ first│tsrif │ignored│││
          │second│dnoces│ignored│││
          │ third│driht │ignored│││
          └──────┴──────┴───────┴┴┘
        TABLE
      end
    end

    context 'with a render block' do
      subject do
        described_class.new(*procs) do |renderer|
          renderer.border.separator = [0, 2]
        end
      end

      it 'applies the block to the renderer' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌──────┬──────┬───────┬┬┐
          │first │tsrif │ignored│││
          ├──────┼──────┼───────┼┼┤
          │second│dnoces│ignored│││
          │third │driht │ignored│││
          └──────┴──────┴───────┴┴┘
        TABLE
      end
    end

    context 'with a string default' do
      subject do
        described_class.new(*procs, default: '(none)')
      end

      it 'replaces nil and empty string' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌──────┬──────┬───────┬──────┬──────┐
          │first │tsrif │ignored│(none)│(none)│
          │second│dnoces│ignored│(none)│(none)│
          │third │driht │ignored│(none)│(none)│
          └──────┴──────┴───────┴──────┴──────┘
        TABLE
      end
    end

    context 'with defaults' do
      let(:expanded_procs) { procs.dup.tap { |p| p << ->(_) {} } }
      let(:defaults) { ['skip', 'skip', 'skip', 'nil-column'] }

      subject do
        described_class.new(*expanded_procs, default: 'repeat-column')
      end

      before do
        subject.callables.each_with_index { |c, idx| c.config[:default] = defaults[idx] }
      end

      it 'replaces on a per column basis with a repeat' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌──────┬──────┬───────┬──────────┬─────────────┬─────────────┐
          │first │tsrif │ignored│nil-column│repeat-column│repeat-column│
          │second│dnoces│ignored│nil-column│repeat-column│repeat-column│
          │third │driht │ignored│nil-column│repeat-column│repeat-column│
          └──────┴──────┴───────┴──────────┴─────────────┴─────────────┘
        TABLE
      end
    end

    context 'with yes/no flags' do
      subject do
        described_class.new(*procs_with_bools, yes: 'Yes', no: 'No')
      end

      it 'replaces true/false with either a static or column based value' do
        expect(subject.render(*data)).to eq(<<~TABLE.chomp)
          ┌──────┬──────┬───────┬┬┬───┬──┐
          │first │tsrif │ignored│││Yes│No│
          │second│dnoces│ignored│││Yes│No│
          │third │driht │ignored│││Yes│No│
          └──────┴──────┴───────┴┴┴───┴──┘
        TABLE
      end
    end
  end
end
