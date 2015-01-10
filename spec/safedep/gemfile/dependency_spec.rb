require 'safedep/gemfile'

module Safedep
  class Gemfile
    describe Dependency do
      include FileHelper
      include_context 'isolated environment'

      let(:gemfile) do
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
          gem 'rubocop', require: false
        end
      END

      describe '#name' do
        let(:dependency) { gemfile.dependencies.first }

        it 'returns the name of the gem' do
          expect(dependency.name).to eq('rake')
        end
      end

      describe '#version_specifier' do
        subject(:version_specifier) { dependency.version_specifier }

        context 'when the dependency has version specifier' do
          let(:dependency) { gemfile.find_dependency('rspec') }

          it 'returns the specifier' do
            expect(version_specifier).to eq('~> 3.1')
          end
        end

        context 'when the dependency has no version specifier' do
          context 'and has no options' do
            let(:dependency) { gemfile.find_dependency('rake') }
            it { should be_nil }
          end

          context 'but has options' do
            let(:dependency) { gemfile.find_dependency('rubocop') }
            it { should be_nil }
          end
        end
      end

      describe '#version_specifier=' do
        context 'when the dependency has version specifier' do
          let(:dependency) { gemfile.find_dependency('rspec') }

          let(:expected_source) { <<-END.strip_indent }
            source 'https://rubygems.org'

            gemspec

            group :development, :test do
              gem 'rake'
              gem 'rspec', '> 4.0'
              gem 'rubocop', require: false
            end
          END

          it 'replaces the existing specifier with the passed specifier' do
            dependency.version_specifier = '> 4.0'
            gemfile.rewrite!
            expect(File.read(gemfile.path)).to eq(expected_source)
          end
        end

        context 'when the dependency has no version specifier' do
          context 'and has no options' do
            let(:dependency) { gemfile.find_dependency('rake') }

            let(:expected_source) { <<-END.strip_indent }
              source 'https://rubygems.org'

              gemspec

              group :development, :test do
                gem 'rake', '~> 10.1'
                gem 'rspec', '~> 3.1'
                gem 'rubocop', require: false
              end
            END

            it 'adds the passed specifier' do
              dependency.version_specifier = '~> 10.1'
              gemfile.rewrite!
              expect(File.read(gemfile.path)).to eq(expected_source)
            end
          end

          context 'but has options' do
            let(:dependency) { gemfile.find_dependency('rubocop') }

            let(:expected_source) { <<-END.strip_indent }
              source 'https://rubygems.org'

              gemspec

              group :development, :test do
                gem 'rake'
                gem 'rspec', '~> 3.1'
                gem 'rubocop', '~> 0.28', require: false
              end
            END

            it 'adds the passed specifier' do
              dependency.version_specifier = '~> 0.28'
              gemfile.rewrite!
              expect(File.read(gemfile.path)).to eq(expected_source)
            end
          end
        end
      end
    end
  end
end
