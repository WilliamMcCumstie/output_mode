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

RSpec.describe OutputMode::Outputs::Templated do
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
      it 'returns the rendered data' do
        expect(subject.render(*data)).to eq(<<~RENDERED)
          \s* first
           * tsrif
           * ignored

           * 
           * true
           * false

           * second
           * dnoces
           * ignored

           * 
           * true
           * false

           * third
           * driht
           * ignored

           * 
           * true
           * false
        RENDERED
      end

      it 'uses the generate method' do
        data.each do |datum|
          expect(subject).to receive(:generate).with(datum).and_call_original
        end
        subject.render(*data)
      end
    end

    context 'with a custom separator' do
      subject { described_class.new(*procs, separator: "****\n") }

      it 'use the new separator' do
        expect(subject.render(*data)).to eq(<<~RENDERED)
         * first
         * tsrif
         * ignored

         * 
         * true
         * false
        ****
         * second
         * dnoces
         * ignored

         * 
         * true
         * false
        ****
         * third
         * driht
         * ignored

         * 
         * true
         * false
        RENDERED
      end
    end
  end

  context 'with fields' do
    # Intentionally includes a list attribute
    let(:fields) do
      (0..(procs.length - 4)).map { |i| "field#{i}" }.tap do |f|
        f.unshift(nil)
        f << 'repeated'
      end
    end

    let(:colorize) { false }

    subject do
      described_class.new(*procs, fields: fields, colorize: colorize)
    end

    it 'uses the field output' do
      expect(subject.render(*data)).to eq(<<~RENDERED)
         * first
          field0: tsrif
          field1: ignored
          field2: 
          field3: 
        repeated: true
        repeated: false

         * second
          field0: dnoces
          field1: ignored
          field2: 
          field3: 
        repeated: true
        repeated: false

         * third
          field0: driht
          field1: ignored
          field2: 
          field3: 
        repeated: true
        repeated: false
      RENDERED
    end

    context 'when colorized' do
      let(:colorize) { true }

      it 'includes the color control characters' do
        value = " \e[1m*\e[0m \e[32mfirst\e[0m\n  \e[34;1mfield0\e[0m\e[1m:\e[0m \e[32mtsrif\e[0m\n  \e[34;1mfield1\e[0m\e[1m:\e[0m \e[32mignored\e[0m\n  \e[34;1mfield2\e[0m\e[1m:\e[0m \n  \e[34;1mfield3\e[0m\e[1m:\e[0m \n\e[34;1mrepeated\e[0m\e[1m:\e[0m \e[32mtrue\e[0m\n\e[34;1mrepeated\e[0m\e[1m:\e[0m \e[32mfalse\e[0m\n\n \e[1m*\e[0m \e[32msecond\e[0m\n  \e[34;1mfield0\e[0m\e[1m:\e[0m \e[32mdnoces\e[0m\n  \e[34;1mfield1\e[0m\e[1m:\e[0m \e[32mignored\e[0m\n  \e[34;1mfield2\e[0m\e[1m:\e[0m \n  \e[34;1mfield3\e[0m\e[1m:\e[0m \n\e[34;1mrepeated\e[0m\e[1m:\e[0m \e[32mtrue\e[0m\n\e[34;1mrepeated\e[0m\e[1m:\e[0m \e[32mfalse\e[0m\n\n \e[1m*\e[0m \e[32mthird\e[0m\n  \e[34;1mfield0\e[0m\e[1m:\e[0m \e[32mdriht\e[0m\n  \e[34;1mfield1\e[0m\e[1m:\e[0m \e[32mignored\e[0m\n  \e[34;1mfield2\e[0m\e[1m:\e[0m \n  \e[34;1mfield3\e[0m\e[1m:\e[0m \n\e[34;1mrepeated\e[0m\e[1m:\e[0m \e[32mtrue\e[0m\n\e[34;1mrepeated\e[0m\e[1m:\e[0m \e[32mfalse\e[0m\n"
        expect(subject.render(*data)).to eq(value)
      end
    end

    shared_examples 'with custom template' do
      let(:fields) do
        (0..procs.length).map { |i| "field#{i.to_s * i}" }
      end

      let(:template) do
        <<~ERB
          # Section 1 Start
          <% each(:section1) do |value, field:, padding:, **_| -%>
          <%= padding -%><%= field -%>: <%= value %>
          <% end -%>

          # Section 2 Start
          <% each(:section2) do |value, field:, padding:, **_| -%>
          <%= padding -%><%= field -%>: <%= value %>
          <% end -%>
          # End
        ERB
      end

      let(:sections) { [:section2, :section1, :section2, :skip] }
      subject do
        described_class.new(
          *procs, sections: sections, template: template_input, fields: fields
        )
      end

      it 'can be grouped' do
        expect(subject.render(*data)).to eq(<<~RENDERED)
          # Section 1 Start
          field1: tsrif

          # Section 2 Start
            field: first
          field22: ignored
          # End

          # Section 1 Start
          field1: dnoces

          # Section 2 Start
            field: second
          field22: ignored
          # End

          # Section 1 Start
          field1: driht

          # Section 2 Start
            field: third
          field22: ignored
          # End
        RENDERED
      end
    end

    context 'with sections and erb template' do
      let(:template_input) do
        ERB.new(template, nil, '-')
      end

      include_examples 'with custom template'
    end

    context 'with sections and string template' do
      let(:template_input) { template }

      include_examples 'with custom template'
    end
  end
end
