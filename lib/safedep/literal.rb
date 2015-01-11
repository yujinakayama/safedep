module Safedep
  module Literal
    module_function

    def value(node)
      concretize(node)
    end

    def concretize(node) # rubocop:disable CyclomaticComplexity
      return nil unless node

      case node.type
      when :true                    then true
      when :false                   then false
      when :nil                     then nil
      when :int, :float, :str, :sym then node.children.first
      when :regexp                  then concretize_regexp(node)
      when :array                   then concretize_array(node)
      when :hash                    then concretize_hash(node)
      when :irange, :erange         then concretize_range(node)
      end
    end

    def concretize_regexp(regexp_node)
      str_node, *_interporated_nodes, regopt_node = *regexp_node
      string = str_node.children.first
      options = regopt_node.children.map(&:to_s).reduce(:+)
      eval("/#{string}/#{options}") # rubocop:disable Eval
    end

    def concretize_array(array_node)
      array_node.children.map { |child_node| concretize(child_node) }
    end

    def concretize_hash(hash_node)
      hash_node.children.each_with_object({}) do |pair_node, hash|
        key_node, value_node = *pair_node
        key = concretize(key_node)
        hash[key] = concretize(value_node) if key
      end
    end

    def concretize_range(range_node)
      values = range_node.children.map { |child_node| concretize(child_node) }
      Range.new(*values, range_node.type == :erange)
    end
  end
end
