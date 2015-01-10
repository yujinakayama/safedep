require 'safedep/cli/option_parser'
require 'safedep/runner'

module Safedep
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      OptionParser.new.parse(args)
      Runner.run
      puts 'Done.'
    end
  end
end
