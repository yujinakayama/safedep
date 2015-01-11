require 'safedep/gemspec'

module Safedep
  class Gemspec
    describe Dependency, :gemspec do
      include FileHelper
      include_context 'isolated environment'

      let(:gemspec_source) { <<-END.strip_indent }
        Gem::Specification.new do |spec|
          spec.name = 'safedep'
          spec.add_dependency 'parser'
          spec.add_runtime_dependency 'bundler', '>= 1.3.1', '< 2.0'
          spec.add_runtime_dependency 'astrolabe', ['>= 1.3', '< 2.0']
          spec.add_development_dependency 'rspec', '~> 3.1'
        end
      END

      describe '#name' do
        let(:dependency) { gemspec.dependencies.first }

        it 'returns the name of the gem' do
          expect(dependency.name).to eq('parser')
        end
      end

      describe '#groups' do
        subject { dependency.groups }

        context 'when the dependency is specified via #add_dependency' do
          let(:dependency) { gemspec.find_dependency('parser') }
          it { should be_empty }
        end

        context 'when the dependency is specified via #add_runtime_dependency' do
          let(:dependency) { gemspec.find_dependency('astrolabe') }
          it { should be_empty }
        end

        context 'when the dependency is specified via #add_runtime_dependency' do
          let(:dependency) { gemspec.find_dependency('rspec') }
          it { should eq([:development]) }
        end
      end

      describe '#version_specifiers' do
        subject(:version_specifier) { dependency.version_specifiers }

        context 'when the dependency has no version specifier' do
          let(:dependency) { gemspec.find_dependency('parser') }
          it { should be_empty }
        end

        context 'when the dependency has a version specifier' do
          let(:dependency) { gemspec.find_dependency('rspec') }

          it 'returns the specifier' do
            expect(version_specifier).to eq(['~> 3.1'])
          end
        end

        context 'when the dependency has multiple version specifiers' do
          let(:dependency) { gemspec.find_dependency('bundler') }

          it 'returns the specifiers' do
            expect(version_specifier).to eq(['>= 1.3.1', '< 2.0'])
          end
        end

        context 'when the dependency has multiple version specifiers in an array' do
          let(:dependency) { gemspec.find_dependency('astrolabe') }

          it 'returns the specifiers' do
            expect(version_specifier).to eq(['>= 1.3', '< 2.0'])
          end
        end
      end

      describe '#version_specifiers=' do
        let(:rewritten_source) { File.read(gemspec.path) }

        context 'when the dependency has no version specifier' do
          let(:dependency) { gemspec.find_dependency('parser') }

          let(:expected_source) { <<-END.strip_indent }
            Gem::Specification.new do |spec|
              spec.name = 'safedep'
              spec.add_dependency 'parser', '~> 2.2'
              spec.add_runtime_dependency 'bundler', '>= 1.3.1', '< 2.0'
              spec.add_runtime_dependency 'astrolabe', ['>= 1.3', '< 2.0']
              spec.add_development_dependency 'rspec', '~> 3.1'
            end
          END

          it 'adds the passed specifier' do
            dependency.version_specifiers = '~> 2.2'
            gemspec.rewrite!
            expect(rewritten_source).to eq(expected_source)
          end
        end

        context 'when the dependency has a version specifier' do
          let(:dependency) { gemspec.find_dependency('rspec') }

          let(:expected_source) { <<-END.strip_indent }
            Gem::Specification.new do |spec|
              spec.name = 'safedep'
              spec.add_dependency 'parser'
              spec.add_runtime_dependency 'bundler', '>= 1.3.1', '< 2.0'
              spec.add_runtime_dependency 'astrolabe', ['>= 1.3', '< 2.0']
              spec.add_development_dependency 'rspec', '> 4.0'
            end
          END

          it 'replaces the existing specifier with the passed specifier' do
            dependency.version_specifiers = '> 4.0'
            gemspec.rewrite!
            expect(rewritten_source).to eq(expected_source)
          end
        end

        context 'when the dependency has multiple version specifiers' do
          let(:dependency) { gemspec.find_dependency('bundler') }

          let(:expected_source) { <<-END.strip_indent }
            Gem::Specification.new do |spec|
              spec.name = 'safedep'
              spec.add_dependency 'parser'
              spec.add_runtime_dependency 'bundler', '~> 2.0'
              spec.add_runtime_dependency 'astrolabe', ['>= 1.3', '< 2.0']
              spec.add_development_dependency 'rspec', '~> 3.1'
            end
          END

          it 'replaces the existing specifiers with the passed specifier' do
            dependency.version_specifiers = '~> 2.0'
            gemspec.rewrite!
            expect(rewritten_source).to eq(expected_source)
          end
        end

        context 'when the dependency has multiple version specifiers in an array' do
          let(:dependency) { gemspec.find_dependency('astrolabe') }

          let(:expected_source) { <<-END.strip_indent }
            Gem::Specification.new do |spec|
              spec.name = 'safedep'
              spec.add_dependency 'parser'
              spec.add_runtime_dependency 'bundler', '>= 1.3.1', '< 2.0'
              spec.add_runtime_dependency 'astrolabe', '~> 2.0'
              spec.add_development_dependency 'rspec', '~> 3.1'
            end
          END

          it 'replaces the existing specifiers with the passed specifier' do
            dependency.version_specifiers = '~> 2.0'
            gemspec.rewrite!
            expect(rewritten_source).to eq(expected_source)
          end
        end

        context 'when multiple specifiers are passed' do
          let(:dependency) { gemspec.find_dependency('rspec') }

          let(:expected_source) { <<-END.strip_indent }
            Gem::Specification.new do |spec|
              spec.name = 'safedep'
              spec.add_dependency 'parser'
              spec.add_runtime_dependency 'bundler', '>= 1.3.1', '< 2.0'
              spec.add_runtime_dependency 'astrolabe', ['>= 1.3', '< 2.0']
              spec.add_development_dependency 'rspec', '>= 3.1', '< 4.0'
            end
          END

          it 'replaces the existing specifier with the passed specifier' do
            dependency.version_specifiers = ['>= 3.1', '< 4.0']
            gemspec.rewrite!
            expect(rewritten_source).to eq(expected_source)
          end
        end
      end
    end
  end
end
