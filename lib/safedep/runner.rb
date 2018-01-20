require 'safedep/configuration'
require 'safedep/error'
require 'safedep/gemfile_lock'
require 'safedep/policy/sem_ver'
require 'gemologist'

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
          raise Error, "#{dep.name.inspect} definition is not found in #{gemfile_lock.path}. " \
                      'Please run `bundle install`.'
        end

        dep.version_specifiers = version_specifiers(lockfile_dep.version)
      end

      gemfiles.each(&:save)
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
        Gemologist::Gemspec.new(path) if path
      end
    end

    def gemfile
      @gemfile ||= begin
        check_file_existence!(GEMFILE_PATH)
        Gemologist::Gemfile.new(GEMFILE_PATH)
      end
    end

    def gemfile_lock
      @gemfile_lock ||= begin
        check_file_existence!(GEMFILE_LOCK_PATH, 'Please run `bundle install`.')
        Safedep::GemfileLock.new(GEMFILE_LOCK_PATH)
      end
    end

    def check_file_existence!(path, additional_message = nil)
      return if File.exist?(path)
      message = "#{path} is not found."
      message << ' ' + additional_message if additional_message
      raise Error, message
    end

    def should_ignore?(dependency)
      return true unless dependency.version_specifiers.empty?
      return true unless (dependency.groups & configuration.skipped_groups).empty?
      %i[git github path].any? { |key| dependency.options[key] }
    end

    def version_specifiers(version)
      Policy::SemVer.version_specifiers(version)
    end
  end
end
