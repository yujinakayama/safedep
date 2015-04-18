require 'safedep/runner'

module Safedep
  describe Runner do
    include FileHelper
    include_context 'isolated environment'

    subject(:runner) { Runner.new }

    let(:configuration) { runner.configuration }

    let(:expected_gemfile_source) { <<-END.strip_indent }
      source 'https://rubygems.org'

      gemspec

      group :development, :test do
        gem 'rake', '~> 10.4'
        gem 'rspec', '~> 3.1'
        gem 'rubocop', '~> 0.28', require: false
      end
    END

    let(:expected_gemspec_source) { <<-END.strip_indent }
      Gem::Specification.new do |spec|
        spec.name = 'safedep'
        spec.add_runtime_dependency 'parser', '~> 2.2'
        spec.add_runtime_dependency 'astrolabe', '~> 1.3'
      end
    END

    context 'when there is no Gemfile.lock' do
      it 'raises error' do
        expect { runner.run }.to raise_error(/Gemfile\.lock/)
      end
    end

    context 'when there is Gemfile.lock', :lockfile do
      context 'but no Gemfile' do
        it 'raises error' do
          expect { runner.run }.to raise_error(/Gemfile /)
        end
      end

      context 'and Gemfile', :gemfile do
        it 'rewrites the Gemfile' do
          runner.run
          expect(rewritten_gemfile_source).to eq(expected_gemfile_source)
        end

        context 'and gemspec', :gemspec do
          it 'rewrites both the Gemfile and the gemspec' do
            runner.run
            expect(rewritten_gemfile_source).to eq(expected_gemfile_source)
            expect(rewritten_gemspec_source).to eq(expected_gemspec_source)
          end
        end
      end
    end

    context 'when a dependency specified in Gemfile does not exist in Gemfile.lock', :gemfile, :lockfile do
      let!(:lockfile) do
        require 'gemologist/gemfile_lock'
        create_file(lockfile_path, invalid_lockfile_source)
        Gemologist::GemfileLock.new(lockfile_path)
      end

      let(:invalid_lockfile_source) { lockfile_source.gsub(/.*rspec.*\n/, '') }

      it 'raises error' do
        expect { runner.run }.to raise_error(/rspec.+Gemfile\.lock/)
      end
    end

    context 'when bundler dependency is specified in gemspec', :gemfile, :lockfile do
      let!(:gemspec) do
        require 'gemologist/gemspec'
        create_file(gemspec_path, gemspec_source)
        Gemologist::Gemspec.new(gemspec_path)
      end

      let(:gemspec_path) { 'safedep.gemspec' }

      let(:gemspec_source) { <<-END.strip_indent }
        Gem::Specification.new do |spec|
          spec.name = 'safedep'
          spec.add_runtime_dependency 'bundler'
        end
      END

      it 'does not raise error' do
        expect { runner.run }.not_to raise_error
      end
    end

    context 'when Configuration#skipped_groups is specified', :gemspec, :gemfile, :lockfile do
      before do
        configuration.skipped_groups = ['development']
      end

      let(:development_dependencies) do
        runner.dependencies.select { |dep| dep.groups.include?(:development) }
      end

      it 'does not modify dependencies that belong to any of the groups' do
        development_dependencies.each do |dep|
          expect(dep).not_to receive(:version_specifiers=)
        end

        runner.run
      end
    end

    context 'when a dependency has :git option', :gemfile, :lockfile do
      let(:gemfile_source) { <<-END.strip_indent }
        source 'https://rubygems.org'

        group :development, :test do
          gem 'rubocop', git: 'https://github.com/bbatsov/rubocop.git'
        end
      END

      it 'does not add version specifiers to the dependency' do
        runner.run
        expect(rewritten_gemfile_source).to eq(gemfile_source)
      end
    end

    context 'when a dependency has :github option', :gemfile, :lockfile do
      let(:gemfile_source) { <<-END.strip_indent }
        source 'https://rubygems.org'

        group :development, :test do
          gem 'rubocop', github: 'bbatsov/rubocop.git'
        end
      END

      it 'does not add version specifiers to the dependency' do
        runner.run
        expect(rewritten_gemfile_source).to eq(gemfile_source)
      end
    end

    context 'when a dependency has :path option', :gemfile, :lockfile do
      let(:gemfile_source) { <<-END.strip_indent }
        source 'https://rubygems.org'

        group :development, :test do
          gem 'rubocop', path: '../rubocop'
        end
      END

      it 'does not add version specifiers to the dependency' do
        runner.run
        expect(rewritten_gemfile_source).to eq(gemfile_source)
      end
    end
  end
end
