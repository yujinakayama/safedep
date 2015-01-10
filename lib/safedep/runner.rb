require 'safedep/gemspec'
require 'safedep/gemfile'
require 'safedep/gemfile_lock'

module Safedep
  class Runner
    def self.run
      new.run
    end

    def run
      dependencies = gemspec.dependencies + gemfile.dependencies

      dependencies.each do |dep|
        next if dep.version_specifier
        lockfile_dep = gemfile_lock.find_dependency(dep.name)
        dep.version_specifier = safe_version_specifier(lockfile_dep.version)
      end

      [gemspec, gemfile].each(&:rewrite!)
    end

    def gemspec
      @gemspec ||= begin
        path = Dir['*.gemspec'].first
        Gemspec.new(path)
      end
    end

    def gemfile
      @gemfile ||= Gemfile.new('Gemfile')
    end

    def gemfile_lock
      @gemfile_lock ||= GemfileLock.new('Gemfile.lock')
    end

    def safe_version_specifier(version)
      '~> ' << version.to_s.split('.').first(2).join('.')
    end
  end
end
