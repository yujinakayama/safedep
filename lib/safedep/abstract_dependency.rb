require 'safedep/literal'

module Safedep
  class AbstractDependency
    attr_reader :node, :rewriter

    def self.valid_node?(node)
      return false unless node.send_type?
      _receiver_node, message, name_node, = *node
      method_names.include?(message) && name_node.str_type?
    end

    def self.method_names
      fail NotImplementedError
    end

    def initialize(node, rewriter)
      fail 'Invalid node.' unless self.class.valid_node?(node)
      @node = node
      @rewriter = rewriter
    end

    def name
      name_node.children.first
    end

    def groups
      fail NotImplementedError
    end

    def version_specifiers
      @version_specifiers ||= version_nodes.map { |node| Literal.value(node) }.flatten
    end

    def version_specifiers=(*specifiers)
      source = specifiers.flatten.map { |specifier| "'#{specifier}'" }.join(', ')

      if version_nodes.empty?
        rewriter.insert_after(name_node.loc.expression, ", #{source}")
      else
        rewriter.replace(version_range, source)
      end
    end

    def options
      {}
    end

    private

    def method_name
      node.children[1]
    end

    def name_node
      node.children[2]
    end

    def trailing_nodes
      node.children[3..-1]
    end

    def version_nodes
      fail NotImplementedError
    end

    def version_range
      version_nodes.first.loc.expression.join(version_nodes.last.loc.expression)
    end
  end
end
