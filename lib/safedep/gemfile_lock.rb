require 'bundler'
require 'ostruct'

module Safedep
  class GemfileLock
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def find_dependency(name)
      dependencies.find { |dep| dep.name == name }
    end

    def dependencies
      @dependencies ||= lockfile.specs + [bundler_dependency]
    end

    private

    def lockfile
      @lockfile ||= begin
        content = File.read(path)
        Bundler::LockfileParser.new(content)
      end
    end

    def bundler_dependency
      OpenStruct.new(name: 'bundler', version: Bundler::VERSION)
    end
  end
end
