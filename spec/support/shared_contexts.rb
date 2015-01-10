
shared_context 'isolated environment' do
  around do |example|
    require 'tmpdir'
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        example.run
      end
    end
  end
end

shared_context 'with gemspec', :gemspec do
  let!(:gemspec) do
    require 'safedep/gemspec'
    create_file(gemspec_path, gemspec_source)
    Safedep::Gemspec.new(gemspec_path)
  end

  let(:gemspec_path) { 'safedep.gemspec' }

  let(:gemspec_source) { <<-END.strip_indent }
    Gem::Specification.new do |spec|
      spec.name = 'safedep'
      spec.add_runtime_dependency 'parser'
      spec.add_runtime_dependency 'astrolabe'
    end
  END

  let(:rewritten_gemspec_source) { File.read(gemspec_path) }
end

shared_context 'with Gemfile', :gemfile do
  let!(:gemfile) do
    require 'safedep/gemfile'
    create_file(gemfile_path, gemfile_source)
    Safedep::Gemfile.new(gemfile_path)
  end

  let(:gemfile_path) { 'Gemfile' }

  let(:gemfile_source) { <<-END.strip_indent }
    source 'https://rubygems.org'

    gemspec

    group :development, :test do
      gem 'rake'
      gem 'rspec'
      gem 'rubocop', require: false
    end
  END

  let(:rewritten_gemfile_source) { File.read(gemfile_path) }
end

shared_context 'with Gemfile.lock', :lockfile do
  let!(:lockfile) do
    require 'safedep/gemfile_lock'
    create_file(lockfile_path, lockfile_source)
    Safedep::GemfileLock.new(lockfile_path)
  end

  let(:lockfile_path) { 'Gemfile.lock' }

  let(:lockfile_source) { <<-END.strip_indent }
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
end
