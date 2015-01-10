require 'safedep/abstract_dependency'

module Safedep
  class Gemspec
    class Dependency < AbstractDependency
      METHOD_NAMES = [:add_runtime_dependency, :add_development_dependency, :add_dependency].freeze

      def self.method_names
        METHOD_NAMES
      end

      def groups
        case method_name
        when :add_development_dependency
          [:development]
        else
          []
        end
      end
    end
  end
end
