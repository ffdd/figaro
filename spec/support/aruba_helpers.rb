require "aruba/api"

module ArubaHelpers
  def insert_into_file_after(file, pattern, addition)
    content = cd(".") { IO.read(file) }
    content.sub!(pattern, "\\0\n#{addition}")
    overwrite_file(file, content)
  end

  def replace_into_file(file, pattern, replacement)
    content = cd(".") { IO.read(file) }
    content.sub!(pattern, replacement)
    overwrite_file(file, content)
  end
end

