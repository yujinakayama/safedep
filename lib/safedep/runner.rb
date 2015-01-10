require 'safedep/gemspec'
require 'safedep/gemfile'
require 'safedep/gemfile_lock'

module Safedep
  class Runner
    def self.run
      new.run
    end

    def run
      dependencies = gemfiles.map(&:dependencies).reduce(:+)

      dependencies.each do |dep|
        next if dep.version_specifier
        lockfile_dep = gemfile_lock.find_dependency(dep.name)
        dep.version_specifier = safe_version_specifier(lockfile_dep.version)
      end

      gemfiles.each(&:rewrite!)
    end

    def gemfiles
      @gemfiles ||= [gemspec, gemfile].compact
    end

    def gemspec
      @gemspec ||= begin
        path = Dir['*.gemspec'].first
        Gemspec.new(path) if path
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
