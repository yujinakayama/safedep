require 'safedep/gemspec'
require 'safedep/gemfile'
require 'safedep/gemfile_lock'

module Safedep
  class Runner
    GEMFILE_PATH = 'Gemfile'.freeze
    GEMFILE_LOCK_PATH = 'Gemfile.lock'.freeze

    def self.run
      new.run
    end

    def run
      validate!

      dependencies.each do |dep|
        next if dep.version_specifier
        lockfile_dep = gemfile_lock.find_dependency(dep.name)
        dep.version_specifier = safe_version_specifier(lockfile_dep.version)
      end

      gemfiles.each(&:rewrite!)
    end

    def validate!
      gemfile_lock
      gemfile
    end

    def dependencies
      @dependencies ||= gemfiles.map(&:dependencies).reduce(:+)
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
      @gemfile ||= begin
        fail "#{GEMFILE_PATH} is not found." unless File.exist?(GEMFILE_PATH)
        Gemfile.new(GEMFILE_PATH)
      end
    end

    def gemfile_lock
      @gemfile_lock ||= begin
        unless File.exist?(GEMFILE_LOCK_PATH)
          fail "#{GEMFILE_LOCK_PATH} is not found. Please run `bundle install`."
        end

        GemfileLock.new(GEMFILE_LOCK_PATH)
      end
    end

    def safe_version_specifier(version)
      '~> ' << version.to_s.split('.').first(2).join('.')
    end
  end
end
