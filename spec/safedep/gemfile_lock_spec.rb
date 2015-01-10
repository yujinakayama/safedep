require 'safedep/gemfile_lock'

module Safedep
  describe GemfileLock, :lockfile do
    include FileHelper
    include_context 'isolated environment'

    describe '#find_dependency' do
      it 'returns the dependency matching the passed name' do
        dependency = lockfile.find_dependency('rspec')
        expect(dependency.name).to eq('rspec')
      end
    end

    describe '#dependencies' do
      let(:dep_names) { lockfile.dependencies.map(&:name) }

      it 'returns an array of the specifications' do
        expect(dep_names).to include('rake', 'rspec', 'rubocop')
      end

      it 'includes "bundler" dependency' do
        dependency = lockfile.find_dependency('bundler')
        expect(dependency.name).to eq('bundler')
        expect(dependency.version).to eq(Bundler::VERSION)
      end
    end
  end
end
