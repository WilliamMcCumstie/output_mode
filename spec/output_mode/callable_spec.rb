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

RSpec.describe OutputMode::Callable do
  let(:modes) { [:test1, :test2, :test3] }
  let(:mode_queries) { modes.map { |m| :"#{m}?" } }
  let(:explicit_negations) { modes.map { |m| :"#{m}!" } }

  let(:arity) { Random.rand(3) }
  let(:demo_proc) do
    args = (1..arity).map { |i| "arg#{i}" }.join(', ')
    args = "|#{args}|" unless args.empty?

    eval "Proc.new { #{args} 'demo' }"
  end

  shared_examples 'common behaviour' do
    it 'responds_to queries' do
      mode_queries.each { |s| expect(subject.respond_to?(s)).to eq(true) }
    end

    it 'responds_to explicit negations' do
      explicit_negations.each { |s| expect(subject.respond_to?(s)).to eq(true) }
    end

    it 'does not respond_to invalid methods' do
      expect(subject.respond_to?(:invalid)).to eq(false)
    end

    it 'wraps the input proc' do
      inputs = (1..arity).map { |i| "input#{i}" }
      expect(subject.call(*inputs)).to eq(demo_proc.call(*inputs))
    end
  end

  shared_examples 'has no modes' do
    it 'returns false to queries' do
      mode_queries.each { |s| expect(subject.send(s)).to eq(false) }
    end
  end

  shared_examples 'has all modes' do
    it 'returns true to queries' do
      mode_queries.each { |s| expect(subject.send(s)).to eq(true) }
    end
  end

  shared_examples 'has no explicit negations' do
    it 'returns true to explicit negations' do
      explicit_negations.each { |s| expect(subject.send(s)).to eq(true) }
    end
  end

  context 'without any inputs' do
    subject { described_class.new(&demo_proc) }

    include_examples 'common behaviour'
    include_examples 'has no modes'
    include_examples 'has no explicit negations'
  end

  context 'with a falsey modes hash input' do
    subject do
      described_class.new(modes: modes.map { |m| [m, false] }.to_h, &demo_proc)
    end

    include_examples 'common behaviour'
    include_examples 'has no modes'

    it 'returns false to explicitly negations' do
      explicit_negations.each { |s| expect(subject.send(s)).to eq(false) }
    end
  end

  context 'with array modes' do
    subject { described_class.new(modes: modes, &demo_proc) }

    include_examples 'common behaviour'
    include_examples 'has all modes'
    include_examples 'has no explicit negations'
  end

  context 'with a truthy modes hash' do
    subject do
      described_class.new(modes: modes.map { |m| [m, true] }.to_h, &demo_proc)
    end

    include_examples 'common behaviour'
    include_examples 'has all modes'
    include_examples 'has no explicit negations'
  end

  context 'with a config' do
    let(:config) { { key: 'some-other-value' } }

    subject do
      described_class.new(**config, &demo_proc)
    end

    it 'stashes the config' do
      expect(subject.config).to eq(config)
    end
  end
end

