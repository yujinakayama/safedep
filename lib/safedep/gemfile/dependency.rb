require 'safedep/abstract_dependency'

module Safedep
  class Gemfile
    class Dependency < AbstractDependency
      METHOD_NAMES = [:gem].freeze

      def self.method_names
        METHOD_NAMES
      end
    end
  end
end