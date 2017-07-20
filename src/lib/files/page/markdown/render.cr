struct Wikicr::Page::Markdown
  module Render
    # Render a partial string between *@cursor* and *to*.
    # Then moves the cursor to *to + 1*.
    private def render_partial_line(b, str, to)
      b << str[@cursor..to] if @cursor <= str.size
      @cursor = to + 1
    end

    # Render the line from @cursor until the end (-1).
    # Then moves the cursor after the last character.
    private def render_full_line(b, str)
      b << str[@cursor..-1] if @cursor >= 0 && @cursor <= str.size
      @cursor = str.size + 1
    end

    private def render_title(b, str)
      # if the char 160 (space) is in a title, it is obviously a mistake.
      render_full_line b, str.gsub(' ', ' ')
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
        @cursor = link_end + 2
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
        @cursor = special_tag_end + 2
      else
        render_full_line b, str
      end
    end
  end
end
