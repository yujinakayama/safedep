module Safedep
  class Configuration
    def skipped_groups
      @skipped_groups ||= []
    end

    def skipped_groups=(groups)
      @skipped_groups = groups.map(&:to_sym)
    end
  end
end
