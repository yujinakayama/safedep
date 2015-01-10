require 'safedep/gemfile'

module Safedep
  describe Gemfile do
    include FileHelper
    include_context 'isolated environment'

    subject(:gemfile) do
      create_file(path, source)
      Gemfile.new(path)
    end

    let(:path) { 'Gemfile' }

    let(:source) { <<-END.strip_indent }
      source 'https://rubygems.org'

      gemspec

      group :development, :test do
        gem 'rake'
        gem 'rspec', '~> 3.1'
        gem 'rubocop', '~> 0.28'
      end
    END

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
