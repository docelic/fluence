module Wikicr::Helpers::Page
  # TODO: move that
  def add_page(page, stack = [] of String)
    String.build do |str|
      Slang.embed("src/views/pages/sitemap.directory.slang", "str")
    end
  end

  # TODO: move that
  def create_toc_line(line)
    "<li>#{line}</li>"
  end

  # TODO: move that
  def add_toc_level(b, index_entry, current_id = 0, last_head = 0)
    return if index_entry.size == current_id
    current_entry = index_entry[current_id]
    current_head = current_entry[0]
    current_head_value = current_entry[1]
    if current_head > last_head
      b << "<ul>" << create_toc_line(current_head_value)
    elsif current_head < last_head
      b << "</ul>" << create_toc_line(current_head_value)
    else
      b << create_toc_line(current_head_value)
    end
    return add_toc_level(b, index_entry, current_id + 1, current_head)
  end

  def add_toc(index_entry)
    # (index_entry.values.map(&.size).sum + index_entry.size * 9)
    toc = String.build do |b|
      add_toc_level(b, index_entry)
    end
    String.build do |str|
      Slang.embed("src/views/pages/toc.slang", "str")
    end
  end
end
