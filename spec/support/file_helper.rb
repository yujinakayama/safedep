module FileHelper
  module_function

  def create_file(file_path, content)
    require 'fileutils'

    file_path = File.expand_path(file_path)
    dir_path = File.dirname(file_path)
    FileUtils.makedirs(dir_path) unless File.exist?(dir_path)

    File.open(file_path, 'w') do |file|
      case content
      when String
        file.puts content
      when Array
        file.puts content.join("\n")
      else
        raise 'Unsupported type!'
      end
    end
  end
end
