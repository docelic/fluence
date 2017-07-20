struct Wikicr::Page::Markdown
  module Render
    private def move_cursor_after(str : String)
      @cursor = str.size + 1
    end

    private def move_cursor_after(i : Int)
      @cursor = i + 1
    end

    # Render a partial string between *@cursor* and *to*.
    # Then moves the cursor to *to + 1*.
    private def render_partial_line(b, str, to)
      b << str[@cursor..to] if @cursor <= str.size
      move_cursor_after to
    end

    # Render the line from @cursor until the end (-1).
    # Then moves the cursor after the last character.
    private def render_full_line(b, str)
      b << str[@cursor..-1] if @cursor >= 0 && @cursor <= str.size
      move_cursor_after str
    end

    private def render_title(b, str)
      # if the char 160 (space) is in a title, it is obviously a mistake.
      str = str.gsub(' ', ' ')

      title_size = str.index ' '
      raise "Parse Error" if title_size.nil?
      head = "h#{title_size}"
      @title += 1
      title = str[title_size..-1].chomp
      b << "<#{head} id=section-#{@title}>#{title}</#{head}>\n"
      move_cursor_after str
    end

    private def render_quote(b, str)
      render_full_line b, str
    end

    private def render_code_tag(b, str)
      render_full_line b, str
      @code_line = !@code_line
    end

    private def render_code(b, str)
      render_full_line b, str
    end

    # Render an internal link into the builder
    private def render_internal_link(b : String::Builder, str : String, link_begin : Int32)
      text_begin = link_begin + 2
      # Search for the end (the content cannot contain ']' because it must be an "alnum" char)
      if (link_end = str.index(']', text_begin)) && str[link_end + 1] == ']'
        text_end = link_end - 1
        text = str[text_begin..text_end]
        # render before the link
        b << str[@cursor..(link_begin - 1)] unless link_begin == 0
        # if the internal link matches [[xxx|yyy]], keep yyy as title
        title_begin = text.index '|', link_begin
        title, url = if title_begin
                       link = text[0...title_begin]
                       title = text[(title_begin + 1)..-1]
                       _, u = @index.find(link, @page)
                       {title, u}
                     else
                       @index.find(text, @page)
                     end
        # write the markdown link
        b << '[' << title << ']' << '(' << url << ')'
        move_cursor_after link_end + 1
      else
        render_full_line b, str
      end
    end

    # Render an special_tag into the builder
    # TODO: handle tag
    # TODO: handle meta-data
    private def render_special_tag(b : String::Builder, str : String, special_tag_begin : Int32)
      text_begin = special_tag_begin + 2
      # Search for the end (the content cannot contain '}' because it must be an "alnum" char)
      if (special_tag_end = str.index('}', text_begin)) && str[special_tag_end + 1] == '}'
        text_end = special_tag_end - 1
        text = str[text_begin..text_end]
        # render before the special_tag
        b << str[@cursor..(special_tag_begin - 1)] unless special_tag_begin == 0
        # write the markdown link
        b << "**Special tag party:** *#{text}*\n"
        move_cursor_after special_tag_end + 1
      else
        render_full_line b, str
      end
    end
  end
end
