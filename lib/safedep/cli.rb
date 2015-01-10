require 'safedep/cli/option_parser'
require 'safedep/runner'

module Safedep
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      OptionParser.parse(args)
      Runner.run
      puts 'Done.'
      true
    rescue Safedep::Error => error
      warn error.message
      false
    end
  end
end
