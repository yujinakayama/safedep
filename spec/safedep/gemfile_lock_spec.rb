require 'safedep/gemfile_lock'

module Safedep
  describe GemfileLock do
    include FileHelper
    include_context 'isolated environment'

    let(:lockfile) do
      create_file(path, source)
      GemfileLock.new(path)
    end

    let(:path) { 'Gemfile.lock' }

    let(:source) { <<-END.strip_indent }
      PATH
        remote: .
        specs:
          safedep (0.0.1)
            astrolabe
            bundler (~> 1.7)
            parser

      GEM
        remote: https://rubygems.org/
        specs:
          ast (2.0.0)
          astrolabe (1.3.0)
            parser (>= 2.2.0.pre.3, < 3.0)
          diff-lcs (1.2.5)
          parser (2.2.0.2)
            ast (>= 1.1, < 3.0)
          powerpack (0.0.9)
          rainbow (2.0.0)
          rake (10.4.2)
          rspec (3.1.0)
            rspec-core (~> 3.1.0)
            rspec-expectations (~> 3.1.0)
            rspec-mocks (~> 3.1.0)
          rspec-core (3.1.7)
            rspec-support (~> 3.1.0)
          rspec-expectations (3.1.2)
            diff-lcs (>= 1.2.0, < 2.0)
            rspec-support (~> 3.1.0)
          rspec-mocks (3.1.3)
            rspec-support (~> 3.1.0)
          rspec-support (3.1.2)
          rubocop (0.28.0)
            astrolabe (~> 1.3)
            parser (>= 2.2.0.pre.7, < 3.0)
            powerpack (~> 0.0.6)
            rainbow (>= 1.99.1, < 3.0)
            ruby-progressbar (~> 1.4)
          ruby-progressbar (1.7.1)

      PLATFORMS
        ruby

      DEPENDENCIES
        rake (~> 10.4)
        rspec (~> 3.1)
        rubocop (~> 0.28)
        safedep!
    END

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
    end
  end
end
