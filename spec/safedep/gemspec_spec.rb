require 'safedep/gemspec'

module Safedep
  describe Gemspec do
    include FileHelper
    include_context 'isolated environment'

    subject(:gemspec) do
      create_file(path, source)
      Gemspec.new(path)
    end

    let(:path) { 'example.gemspec' }

    let(:source) { <<-END.strip_indent }
      Gem::Specification.new do |spec|
        spec.name = 'safedep'
        spec.add_dependency 'parser'
        spec.add_runtime_dependency 'astrolabe', '~> 1.3'
        spec.add_development_dependency 'rspec', '~> 3.1'
      end
    END

    describe '#find_dependency' do
      it 'returns the dependency matching the passed name' do
        dependency = gemspec.find_dependency('rspec')
        expect(dependency.name).to eq('rspec')
      end
    end

    describe '#dependencies' do
      it 'returns an array of the dependencies' do
        expect(gemspec.dependencies.size).to eq(3)
        expect(gemspec.dependencies).to all be_a(Gemspec::Dependency)
      end
    end
  end
end
