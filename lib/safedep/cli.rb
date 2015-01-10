require 'safedep/cli/option_parser'
require 'safedep/runner'

module Safedep
  class CLI
    def self.run(args = ARGV)
      new.run(args)
    end

    def run(args)
      option_parser.parse(args)

      runner = Runner.new(option_parser.configuration)
      runner.run

      puts 'Done.'

      true
    rescue Safedep::Error => error
      warn error.message
      false
    end

    def option_parser
      @option_parser ||= OptionParser.new
    end
  end
end
