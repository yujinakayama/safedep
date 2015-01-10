require 'safedep/abstract_gemfile'

module Safedep
  class Gemspec < AbstractGemfile
    require 'safedep/gemspec/dependency'

    private

    def dependency_class
      Gemspec::Dependency
    end
  end
end
