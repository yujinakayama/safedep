module Safedep
  module Util
    module_function

    def symbolize_keys(original_hash)
      hash = original_hash.dup

      original_hash.each do |key, value|
        hash[key] = symbolize_keys(value) if value.is_a?(Hash)
        hash[key.to_sym] = hash.delete(key) if key.is_a?(String)
      end

      hash
    end
  end
end
