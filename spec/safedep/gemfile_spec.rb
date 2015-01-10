require 'safedep/gemfile'

module Safedep
  describe Gemfile, :gemfile do
    include FileHelper
    include_context 'isolated environment'

    describe '#find_dependency' do
      it 'returns the dependency matching the passed name' do
        dependency = gemfile.find_dependency('rspec')
        expect(dependency.name).to eq('rspec')
      end
    end

    describe '#dependencies' do
      it 'returns an array of the dependencies' do
        expect(gemfile.dependencies.size).to eq(3)
        expect(gemfile.dependencies).to all be_a(Gemfile::Dependency)
      end
    end
  end
end
