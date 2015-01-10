require 'safedep/abstract_dependency'
require 'astrolabe/sexp'

module Safedep
  class Gemfile
    class Dependency < AbstractDependency
      include Astrolabe::Sexp

      METHOD_NAMES = [:gem].freeze

      def self.method_names
        METHOD_NAMES
      end

      def groups
        @groups ||= (groups_via_block + groups_via_option).map(&:to_sym)
      end

      def groups_via_block
        return [] unless group_node
        _receiver_node, _message, *arg_nodes = *group_node
        literal_nodes = arg_nodes.select { |arg_node| arg_node.sym_type? || arg_node.str_type? }
        literal_nodes.map { |literal_node| literal_node.children.first }
      end

      def groups_via_option
        return [] unless options_node

        options_node.each_child_node do |pair_node|
          key_node, value_node = *pair_node

          next unless key_node == s(:sym, :group)

          case value_node.type
          when :sym
            return [value_node.children.first]
          when :array
            literal_nodes = value_node.each_child_node(:sym, :str)
            return literal_nodes.map { |literal_node| literal_node.children.first }
          else
            return []
          end
        end

        []
      end

      def group_node
        candidates = node.each_ancestor(:block).map { |block_node| block_node.children.first }

        candidates.find do |send_node|
          receiver_node, message, = *send_node
          receiver_node.nil? && message == :group
        end
      end
    end
  end
end
