require 'astrolabe/builder'
require 'parser/current'

module Safedep
  class AbstractGemfile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def find_dependency(name)
      dependencies.find { |dep| dep.name == name }
    end

    def dependencies
      @dependencies ||= ast.each_node.with_object([]) do |node, dependencies|
        next unless dependency_class.valid_node?(node)
        dependencies << dependency_class.new(node, source_rewriter)
      end
    end

    def rewrite!
      rewritten_source = source_rewriter.process
      File.write(path, rewritten_source)
    end

    private

    def dependency_class
      fail NotImplementedError
    end

    def ast
      @ast ||= begin
        builder = Astrolabe::Builder.new
        parser = Parser::CurrentRuby.new(builder)
        parser.parse(source_buffer)
      end
    end

    def source_rewriter
      @source_rewriter ||= Parser::Source::Rewriter.new(source_buffer)
    end

    def source_buffer
      @source_buffer ||= Parser::Source::Buffer.new(path).read
    end
  end
end
