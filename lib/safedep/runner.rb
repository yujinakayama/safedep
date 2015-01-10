require 'safedep/gemfile'
require 'safedep/gemfile_lock'

module Safedep
  class Runner
    def self.run
      new.run
    end

    def run
      gemfile.dependencies.each do |gemfile_dep|
        next if gemfile_dep.version_specifier
        lockfile_dep = gemfile_lock.find_dependency(gemfile_dep.name)
        gemfile_dep.version_specifier = safe_version_specifier(lockfile_dep.version)
      end

      gemfile.rewrite!
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
