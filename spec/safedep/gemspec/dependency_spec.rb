require 'safedep/gemspec'

module Safedep
  class Gemspec
    describe Dependency do
      include FileHelper
      include_context 'isolated environment'

      let(:gemspec) do
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

      describe '#name' do
        let(:dependency) { gemspec.dependencies.first }

        it 'returns the name of the gem' do
          expect(dependency.name).to eq('parser')
        end
      end

      describe '#version_specifier' do
        subject(:version_specifier) { dependency.version_specifier }

        context 'when the dependency has version specifier' do
          let(:dependency) { gemspec.find_dependency('rspec') }

          it 'returns the specifier' do
            expect(version_specifier).to eq('~> 3.1')
          end
        end

        context 'when the dependency has no version specifier' do
          let(:dependency) { gemspec.find_dependency('parser') }
          it { should be_nil }
        end
      end

      describe '#version_specifier=' do
        let(:rewritten_source) { File.read(gemspec.path) }

        context 'when the dependency has version specifier' do
          let(:dependency) { gemspec.find_dependency('rspec') }

          let(:expected_source) { <<-END.strip_indent }
            Gem::Specification.new do |spec|
              spec.name = 'safedep'
              spec.add_dependency 'parser'
              spec.add_runtime_dependency 'astrolabe', '~> 1.3'
              spec.add_development_dependency 'rspec', '> 4.0'
            end
          END

          it 'replaces the existing specifier with the passed specifier' do
            dependency.version_specifier = '> 4.0'
            gemspec.rewrite!
            expect(rewritten_source).to eq(expected_source)
          end
        end

        context 'when the dependency has no version specifier' do
          let(:dependency) { gemspec.find_dependency('parser') }

          let(:expected_source) { <<-END.strip_indent }
            Gem::Specification.new do |spec|
              spec.name = 'safedep'
              spec.add_dependency 'parser', '~> 2.2'
              spec.add_runtime_dependency 'astrolabe', '~> 1.3'
              spec.add_development_dependency 'rspec', '~> 3.1'
            end
          END

          it 'adds the passed specifier' do
            dependency.version_specifier = '~> 2.2'
            gemspec.rewrite!
            expect(rewritten_source).to eq(expected_source)
          end
        end
      end
    end
  end
end
