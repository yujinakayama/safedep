module Safedep
  class AbstractDependency
    attr_reader :node, :rewriter

    def self.valid_node?(node)
      return false unless node.send_type?
      _receiver_node, message, name_node, = *node
      method_names.include?(message) && name_node.str_type?
    end

    def self.method_names
      fail NotImplemenetedError
    end

    def initialize(node, rewriter)
      fail 'Invalid node.' unless self.class.valid_node?(node)
      @node = node
      @rewriter = rewriter
    end

    def name
      name_node.children.first
    end

    def version_specifier
      return nil unless version_specifier_node
      version_specifier_node.children.first
    end

    def version_specifier=(version_specifier)
      if version_specifier_node
        rewriter.replace(content_range_of_str_node(version_specifier_node), version_specifier)
      else
        rewriter.insert_after(name_node.loc.expression, ", '#{version_specifier}'")
      end
    end

    private

    def name_node
      node.children[2]
    end

    def version_specifier_node
      return @version_specifier_node if instance_variable_defined?(:@version_specifier_node)
      version_node = node.children[3]
      return @version_specifier_node = nil if version_node.nil? || !version_node.str_type?
      @version_specifier_node = version_node
    end

    def content_range_of_str_node(str_node)
      map = str_node.loc
      Parser::Source::Range.new(
        map.expression.source_buffer,
        map.begin.end_pos,
        map.end.begin_pos
      )
    end
  end
end
