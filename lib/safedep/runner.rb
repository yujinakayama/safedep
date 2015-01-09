require 'astrolabe/builder'
require 'bundler'
require 'parser/current'

module Safedep
  class Runner
    def self.run
      new.run
    end

    def run
      version_missing_gem_nodes.each do |send_node|
        _receiver_node, _message, gem_name_node, = *send_node
        gem_name, = *gem_name_node

        current_gem_version = gem_version_in_lockfile(gem_name)
        version_specification = safe_version_specification(current_gem_version)
        gemfile_rewriter.insert_after(gem_name_node.loc.expression, ", '#{version_specification}'")
      end

      File.write('Gemfile', gemfile_rewriter.process)
    end

    def version_missing_gem_nodes
      @version_missing_gem_nodes ||= gemfile_ast.each_node(:send).select do |send_node|
        _receiver_node, message, gem_name_node, version_node, = *send_node
        next false unless message == :gem
        next false unless gem_name_node.str_type?
        version_node.nil?
      end
    end

    def gemfile_ast
      @gemfile_ast ||= begin
        builder = Astrolabe::Builder.new
        parser = Parser::CurrentRuby.new(builder)
        parser.parse(gemfile_source_buffer)
      end
    end

    def gemfile_rewriter
      @gemfile_rewriter ||= Parser::Source::Rewriter.new(gemfile_source_buffer)
    end

    def gemfile_source_buffer
      @gemfile_source_buffer ||= Parser::Source::Buffer.new('Gemfile').read
    end

    def lockfile
      @lockfile ||= Bundler::LockfileParser.new(File.read('Gemfile.lock'))
    end

    def gem_version_in_lockfile(gem_name)
      lockfile.specs.find { |spec| spec.name == gem_name }.version
    end

    def safe_version_specification(gem_version)
      '~> ' + gem_version.to_s.split('.').first(2).join('.')
    end
  end
end
