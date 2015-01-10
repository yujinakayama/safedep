require 'safedep/runner'

module Safedep
  describe Runner do
    include FileHelper
    include_context 'isolated environment'

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
        expect { Runner.run }.to raise_error(/Gemfile.lock/)
      end
    end

    context 'when there is Gemfile.lock', :lockfile do
      context 'but no Gemfile' do
        it 'raises error' do
          expect { Runner.run }.to raise_error(/Gemfile /)
        end
      end

      context 'and Gemfile', :gemfile do
        it 'rewrites the Gemfile' do
          Runner.run
          expect(rewritten_gemfile_source).to eq(expected_gemfile_source)
        end

        context 'and gemspec', :gemspec do
          it 'rewrites both the Gemfile and the gemspec' do
            Runner.run
            expect(rewritten_gemfile_source).to eq(expected_gemfile_source)
            expect(rewritten_gemspec_source).to eq(expected_gemspec_source)
          end
        end
      end
    end
  end
end
