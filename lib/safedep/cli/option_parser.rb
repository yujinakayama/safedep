require 'optparse'
require 'safedep/configuration'
require 'safedep/version'

module Safedep
  class OptionParser
    attr_reader :configuration

    def initialize(configuration = Configuration.new)
      @configuration = configuration
      setup
    end

    def parse(args)
      args = args.dup
      parser.parse!(args)
      args
    end

    private

    def setup
      define_option('--without GROUP[,GROUP...]') do |arg|
        configuration.skipped_groups = arg.split(',')
      end

      define_option('--version') do
        puts Version.to_s
        exit
      end
    end

    def define_option(*options, &block)
      long_option = options.find { |option| option.start_with?('--') }.split(' ').first
      description_lines = descriptions[long_option]
      parser.on(*options, *description_lines, &block)
    end

    def parser
      @parser ||= begin
        banner = "Usage: #{command_name} [options]\n\n"
        summary_width = 20 # Default
        indentation = ' ' * 2
        ::OptionParser.new(banner, summary_width, indentation)
      end
    end

    def command_name
      File.basename($PROGRAM_NAME)
    end

    def descriptions
      @descriptions ||= {
        '--without' => [
          'Specify groups to skip modification as comma-separated list.'
        ],
        '--version' => [
          "Show #{command_name} version."
        ]
      }
    end
  end
end
