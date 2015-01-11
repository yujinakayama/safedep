module Safedep
  module Util
    LITERAL_TYPES = [:sym, :str].freeze

    module_function

    def literal_values(*nodes)
      nodes.flatten!
      options = nodes.last.is_a?(Hash) ? nodes.pop : {}

      literal_nodes = nodes.select { |node| LITERAL_TYPES.include?(node.type) }
      values = literal_nodes.map { |literal_node| literal_node.children.first }

      case options[:coerce]
      when nil     then values
      when :symbol then values.map(&:to_sym)
      when :string then values.map(&:to_s)
      else fail "Invalid :coerce option: #{options[:coerce].inspect}."
      end
    end
  end
end
