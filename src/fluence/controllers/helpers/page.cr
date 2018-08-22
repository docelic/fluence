module Fluence::Helpers::Page
  # TODO: move that
  def add_page(entries, stack = [] of String)
    String.build do |str|
      Slang.embed("src/fluence/views/pages/pages.directory.slang", "str")
    end
  end
  def add_media(entries, stack = [] of String)
    String.build do |str|
      Slang.embed("src/fluence/views/pages/media.directory.slang", "str")
    end
  end

  # TODO: move that
  def create_toc_line(line, current_id, ends = true)
    "<li><a href=\"##{Fluence::Page.sanitize line}\">#{line}</a>#{ends ? "</li>" : nil}\n"
  end

  # TODO: move that
  def add_toc_level(b, index_entry, current_id = 0, last_head = 0)
    return if index_entry.size == current_id
    current_entry = index_entry[current_id]
    current_head = current_entry[0]
    current_head_value = current_entry[1]
    next_entry = index_entry[current_id + 1]?
    next_head = next_entry ? next_entry[0] : 7
    close_li = next_head <= current_head
    if current_head > last_head
      b << "<ol>\n" << create_toc_line(current_head_value, current_id, close_li)
    elsif current_head < last_head
      b << "</ol></li>\n" << create_toc_line(current_head_value, current_id, close_li)
    else
      b << create_toc_line(current_head_value, current_id, close_li)
    end
    return add_toc_level(b, index_entry, current_id + 1, current_head)
  end

  def add_toc(index_entry)
    # (index_entry.values.map(&.size).sum + index_entry.size * 9)
    toc = String.build do |b|
      add_toc_level(b, index_entry)
    end
    String.build do |str|
      Slang.embed("src/fluence/views/pages/toc.slang", "str")
    end
  end
end
