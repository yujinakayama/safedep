module Safedep
  # http://semver.org/
  module Version
    MAJOR = 0
    MINOR = 3
    PATCH = 1

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
