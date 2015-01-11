require 'safedep/abstract_dependency'
require 'safedep/util'
require 'astrolabe/sexp'

module Safedep
  class Gemfile
    class Dependency < AbstractDependency
      include Util, Astrolabe::Sexp

      METHOD_NAMES = [:gem].freeze

      def self.method_names
        METHOD_NAMES
      end

      def groups
        @groups ||= (groups_via_block + groups_via_option).map(&:to_sym)
      end

      private

      def groups_via_block
        return [] unless group_node
        _receiver_node, _message, *arg_nodes = *group_node
        literal_values(arg_nodes, coerce: :symbol)
      end

      def groups_via_option
        return [] unless options_node

        options_node.each_child_node do |pair_node|
          key_node, value_node = *pair_node

          next unless key_node == s(:sym, :group)

          case value_node.type
          when :sym
            return literal_values(value_node, coerce: :symbol)
          when :array
            return literal_values(value_node.children, coerce: :symbol)
          else
            return []
          end
        end

        []
      end

      # https://github.com/bundler/bundler/blob/v1.7.11/lib/bundler/dsl.rb#L68-L70
      def version_nodes
        @version_nodes ||= trailing_nodes - [options_node]
      end

      def options_node
        node = trailing_nodes.last

        if node && node.hash_type?
          node
        else
          nil
        end
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
