require 'safedep/configuration'
require 'safedep/gemspec'
require 'safedep/gemfile'
require 'safedep/gemfile_lock'
require 'safedep/policy/sem_ver'
require 'safedep/error'

module Safedep
  class Runner
    GEMFILE_PATH = 'Gemfile'.freeze
    GEMFILE_LOCK_PATH = 'Gemfile.lock'.freeze

    attr_reader :configuration

    def initialize(configuration = Configuration.new)
      @configuration = configuration
    end

    def run
      validate!

      dependencies.each do |dep|
        next if should_ignore?(dep)

        lockfile_dep = gemfile_lock.find_dependency(dep.name)

        unless lockfile_dep
          fail Error, "#{dep.name.inspect} definition is not found in #{gemfile_lock.path}. " \
                      'Please run `bundle install`.'
        end

        dep.version_specifier = version_specifier(lockfile_dep.version)
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
        fail Error, "#{GEMFILE_PATH} is not found." unless File.exist?(GEMFILE_PATH)
        Gemfile.new(GEMFILE_PATH)
      end
    end

    def gemfile_lock
      @gemfile_lock ||= begin
        unless File.exist?(GEMFILE_LOCK_PATH)
          fail Error, "#{GEMFILE_LOCK_PATH} is not found. Please run `bundle install`."
        end

        GemfileLock.new(GEMFILE_LOCK_PATH)
      end
    end

    def should_ignore?(dependency)
      return true if dependency.version_specifier
      !(dependency.groups & configuration.skipped_groups).empty?
    end

    def version_specifier(version)
      Policy::SemVer.version_specifier(version)
    end
  end
end
