require 'safedep/gemspec'

module Safedep
  describe Gemspec, :gemspec do
    include FileHelper
    include_context 'isolated environment'

    describe '#find_dependency' do
      it 'returns the dependency matching the passed name' do
        dependency = gemspec.find_dependency('parser')
        expect(dependency.name).to eq('parser')
      end
    end

    describe '#dependencies' do
      it 'returns an array of the dependencies' do
        expect(gemspec.dependencies.size).to eq(2)
        expect(gemspec.dependencies).to all be_a(Gemspec::Dependency)
      end
    end
  end
end
