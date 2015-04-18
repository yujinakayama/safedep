require 'gemologist/gemfile_lock'
require 'bundler'
require 'ostruct'

module Safedep
  class GemfileLock < Gemologist::GemfileLock
    def dependencies
      @dependencies ||= lockfile.specs + [bundler_dependency]
    end

    private

    def bundler_dependency
      OpenStruct.new(name: 'bundler', version: Bundler::VERSION)
    end
  end
end
