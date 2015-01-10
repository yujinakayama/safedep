require 'optparse'
require 'safedep/version'

module Safedep
  class OptionParser
    def self.parse(args)
      new.parse(args)
    end

    def initialize
      setup
    end

    def parse(args)
      args = args.dup
      parser.parse!(args)
      args
    end

    private

    def setup
      define_option('--version') do
        puts Version.to_s
        exit
      end
    end

    def define_option(*options, &block)
      long_option = options.find { |option| option.start_with?('--') }
      description_lines = descriptions[long_option]
      parser.on(*options, *description_lines, &block)
    end

    def parser
      @parser ||= begin
        banner = "Usage: #{command_name} [options]\n\n"
        summary_width = 32 # Default
        indentation = ' ' * 2
        ::OptionParser.new(banner, summary_width, indentation)
      end
    end

    def command_name
      File.basename($PROGRAM_NAME)
    end

    def descriptions
      @descriptions ||= {
        '--version' => [
          "Show #{command_name} version."
        ]
      }
    end
  end
end
