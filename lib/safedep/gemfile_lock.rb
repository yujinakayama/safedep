require 'bundler'

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
      lockfile.specs
    end

    private

    def lockfile
      @lockfile ||= begin
        content = File.read(path)
        Bundler::LockfileParser.new(content)
      end
    end
  end
end
