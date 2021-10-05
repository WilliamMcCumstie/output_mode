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
require 'stringio'

RSpec.describe OutputMode::Formatter do
  [true, false, nil].repeated_permutation(4).each do |bools|
    interactive = bools[0]
    ascii = bools[1]
    verbose = bools[2]
    color = bools[3]

    interactive_str = interactive.nil? ? 'nil' : interactive.to_s
    ascii_str = ascii.nil? ? 'nil' : ascii.to_s
    verbose_str = verbose.nil? ? 'nil' : verbose.to_s
    color_str = color.nil? ? 'nil' : color.to_s

    msg = "when interactive is #{interactive_str}, ascii is #{ascii_str}, verbose is #{verbose_str}, and color is #{color_str}"
    context(msg) do
      subject { described_class.new(interactive: interactive, verbose: verbose, ascii: ascii, color: color) }
      let(:stdout) { nil }

      # Allow stdout to be reset
      before(:each) { $stdout = stdout if stdout }
      around(:each) do |example|
        begin
          example.call
        ensure
          $stdout = STDOUT
        end
      end

      # Generic accessor tests
      it { is_expected.send(interactive ? :to : :not_to, be_interactive) } unless interactive.nil?
      it { is_expected.send(ascii ? :to : :not_to, be_ascii) } unless ascii.nil?
      it { is_expected.send(verbose ? :to : :not_to, be_verbose) } unless verbose.nil?
      it { is_expected.send(color ? :to : :not_to, be_color) } unless color.nil?

      # Test the interaction of the color setting
      case interactive
      when NilClass
        context 'when stdout is a tty' do
          let(:stdout) do
            StringIO.new.tap { |io| allow(io).to receive(:tty?).and_return(true) }
          end

          it { should be_interactive }
          it { should_not be_ascii } if ascii.nil?
          it { should_not be_verbose } if verbose.nil?
        end

        context 'when stdout is a tty' do
          let(:stdout) do
            StringIO.new.tap { |io| allow(io).to receive(:tty?).and_return(false) }
          end

          it { should_not be_interactive }
          it { should be_ascii } if ascii.nil?
          it { should be_verbose } if verbose.nil?
        end
      when TrueClass
        it { should_not be_ascii } if ascii.nil?
        it { should_not be_verbose } if verbose.nil?
      else
        it { should be_ascii } if ascii.nil?
        it { should be_verbose } if verbose.nil?
      end

      # Test the interaction between ascii/interactive and color
      if (ascii || interactive == false) && color.nil?
        it { should_not be_color }
      elsif color.nil?
        context 'when TTY::Color responds true to color?' do
          before { allow(TTY::Color).to receive(:color?).and_return(true) }
          it { should be_color }
        end

        context 'when TTY::Color responds false to color?' do
          before { allow(TTY::Color).to receive(:color?).and_return(false) }
          it { should_not be_color }
        end
      end
    end
  end

  describe '#attribute' do
    subject { described_class.new }

    it 'sets the key in the attributes' do
      subject.attribute :foo, 'bar'
      expect(subject.attributes[:foo]).to eq('bar')
    end
  end

  context 'with an interactive ascii formatter' do
    subject { described_class.new(interactive: true, ascii: true) }

    describe '#yes' do
      it "should equal yes" do
        expect(subject.yes).to eq('yes')
      end
    end

    describe '#no' do
      it "should equal no" do
        expect(subject.no).to eq('no')
      end
    end

    describe '#default' do
      it "should equal (none)" do
        expect(subject.default).to eq('(none)')
      end
    end
  end

  context 'with an interactive non-ascii formatter' do
    subject { described_class.new(interactive: true, ascii: false) }

    describe '#yes' do
      it "should equal ✓" do
        expect(subject.yes).to eq('✓')
      end
    end

    describe '#no' do
      it "should equal ✕" do
        expect(subject.no).to eq('✕')
      end
    end

    describe '#default' do
      it "should equal (none)" do
        expect(subject.default).to eq('(none)')
      end
    end
  end

  context 'with an non-interactive formatter' do
    subject { described_class.new(interactive: false) }

    describe '#yes' do
      it "should equal yes" do
        expect(subject.yes).to eq('yes')
      end
    end

    describe '#no' do
      it "should equal no" do
        expect(subject.no).to eq('no')
      end
    end

    describe '#default' do
      it "should be empty string" do
        expect(subject.default).to eq('')
      end
    end
  end
end
