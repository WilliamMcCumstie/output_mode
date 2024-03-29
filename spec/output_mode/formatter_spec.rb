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
    humanize = bools[0]
    ascii = bools[1]
    verbose = bools[2]
    color = bools[3]

    humanize_str = humanize.nil? ? 'nil' : humanize.to_s
    ascii_str = ascii.nil? ? 'nil' : ascii.to_s
    verbose_str = verbose.nil? ? 'nil' : verbose.to_s
    color_str = color.nil? ? 'nil' : color.to_s

    msg = "when humanize is #{humanize_str}, ascii is #{ascii_str}, verbose is #{verbose_str}, and color is #{color_str}"
    context(msg) do
      subject { described_class.new(humanize: humanize, verbose: verbose, ascii: ascii, color: color) }
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
      it { is_expected.send(humanize ? :to : :not_to, be_humanize) } unless humanize.nil?
      it { is_expected.send(ascii ? :to : :not_to, be_ascii) } unless ascii.nil?
      it { is_expected.send(verbose ? :to : :not_to, be_verbose) } unless verbose.nil?
      it { is_expected.send(color ? :to : :not_to, be_color) } unless color.nil?

      # Test the interaction of the color setting
      case humanize
      when NilClass
        context 'when stdout is a tty' do
          let(:stdout) do
            StringIO.new.tap { |io| allow(io).to receive(:tty?).and_return(true) }
          end

          it { should be_humanize }
          it { should_not be_ascii } if ascii.nil?
          it { should_not be_verbose } if verbose.nil?
        end

        context 'when stdout is a tty' do
          let(:stdout) do
            StringIO.new.tap { |io| allow(io).to receive(:tty?).and_return(false) }
          end

          it { should_not be_humanize }
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

      # Test the interaction between ascii/humanize and color
      if (ascii || humanize == false) && color.nil?
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

  context 'with a formatter' do
    subject { described_class.new }

    describe '#yes' do
      it 'can be overridden' do
        value = "foo-yes"
        subject.yes value
        expect(subject.yes).to eq(value)
      end

      it 'can be overridden by the callable' do
        value = 'callable-yes'
        subject.register(yes: value) { true }
        expect(subject.callables.first.call).to eq(value)
      end
    end

    describe '#no' do
      it 'can be overridden' do
        value = 'foo-no'
        subject.no value
        expect(subject.no).to eq(value)
      end

      it 'can be overridden by the callable' do
        value = 'callable-no'
        subject.register(no: value) { false }
        expect(subject.callables.first.call).to eq(value)
      end
    end

    describe '#default' do
      it 'can be overridden' do
        value = 'foo-default'
        subject.default value
        expect(subject.default).to eq(value)
      end

      it 'can be overridden by the callable' do
        value = 'callable-default'
        subject.register(default: value) { nil }
        expect(subject.callables.first.call).to eq(value)
      end
    end

    describe '#time' do
      it 'can be overridden' do
        value = '%m:%d:%y'
        subject.time value
        expect(subject.time).to eq(value)
      end

      it 'can be overridden by the callable' do
        subject.register(time: "%m:%d:%y") { Time.mktime(2001, 2, 3) }
        expect(subject.callables.first.call).to eq("02:03:01")
      end
    end
  end

  context 'with a verbose formatter' do
    subject { described_class.new(verbose: true) }

    context 'when a callable returns a Time object' do
      let(:time) { Time.new(0) }
      before { subject.register { time } }

      it 'is converted into RFC3339 format' do
        expect(subject.callables.first.call).to eq("0000-01-01T00:00:00+00:00")
      end
    end
  end

  context 'with a non-verbose formatter' do
    subject { described_class.new(verbose: false) }

    context 'when a callable returns a Time object' do
      let(:time) { Time.new(0) }
      before { subject.register { time } }

      it 'is converted into a simplified format' do
        expect(subject.callables.first.call).to eq("01/01/00 00:00")
      end
    end
  end

  context 'with an humanize ascii formatter' do
    subject { described_class.new(humanize: true, ascii: true) }

    describe '#yes' do
      it "should equal yes" do
        expect(subject.yes).to eq('yes')
      end

      it 'wraps registered callables which return true' do
        subject.register { true }
        expect(subject.callables.first.call).to eq('yes')
      end
    end

    describe '#no' do
      it "should equal no" do
        expect(subject.no).to eq('no')
      end

      it 'wraps registered callables which return false' do
        subject.register { false }
        expect(subject.callables.first.call).to eq('no')
      end
    end

    describe '#default' do
      it "should equal (none)" do
        expect(subject.default).to eq('(none)')
      end

      it 'wraps registered callables which return nil' do
        subject.register { nil }
        expect(subject.callables.first.call).to eq('(none)')
      end
    end
  end

  context 'with an humanize non-ascii formatter' do
    subject { described_class.new(humanize: true, ascii: false) }

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

  context 'with an non-humanize formatter' do
    subject { described_class.new(humanize: false) }

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
