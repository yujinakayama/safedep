module Safedep
  module Policy
    class SemVer
      attr_reader :version, :major, :minor, :patch, :suffix

      def self.version_specifiers(version)
        new(version).version_specifiers
      end

      def initialize(version)
        @version = if version.is_a?(Gem::Version)
                     version
                   else
                     Gem::Version.new(version)
                   end

        decompose_version
      end

      def version_specifiers
        specifier = '~> ' + [major, minor].join('.')
        requirement = Gem::Requirement.new(specifier)

        if requirement.satisfied_by?(version)
          [specifier]
        else
          nil
        end
      end

      private

      def decompose_version
        elements =  version.to_s.split('.')

        [:major, :minor, :patch].each do |role|
          if elements.first && elements.first.match(/^\d+$/)
            instance_variable_set("@#{role}", elements.shift)
          else
            instance_variable_set("@#{role}", '0')
          end
        end

        @suffix = elements.shift if elements.first && !elements.first.match(/^\d+$/)
      end
    end
  end
end
