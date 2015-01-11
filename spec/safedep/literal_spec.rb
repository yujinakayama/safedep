require 'safedep/literal'
require 'astrolabe/builder'
require 'parser/current'

module Safedep
  describe Literal do
    let(:node) do
      builder = Astrolabe::Builder.new
      parser = Parser::CurrentRuby.new(builder)
      parser.parse(source_buffer)
    end

    let(:source_buffer) do
      Parser::Source::Buffer.new('(string)').tap do |buffer|
        buffer.source = source
      end
    end

    describe '.value' do
      subject { Literal.value(node) }

      [
        true,
        false,
        nil,
        123,
        3.14,
        'foo',
        :foo,
        /foo/im,
        ['foo', 123],
        { 'foo' => 123, bar: false },
        1..3,
        1...3,
        { 'foo' => [:bar, { baz: 3.14 }] }
      ].each do |value|
        context "with #{value.inspect} node" do
          let(:source) { value.inspect }
          it { should eq(value) }
        end
      end

      context 'when nil is passed' do
        let(:node) { nil }
        it { should be_nil }
      end
    end
  end
end
