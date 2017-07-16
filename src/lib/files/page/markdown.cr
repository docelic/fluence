struct Wikicr::Page::Markdown
  property text : String
  property index : Page::Index
  property page : Page
  @cursor : Int32
  @code_line : Bool

  def initialize(@text, @page, @index)
    @cursor = 0
    @code_line = false
  end

  # Build a new String which render a valid markdown from the wikimd
  def build : String
    @cursor = 0
    @code_line = false
    estimated_size = (@text.size + @text.count("[") * 8)
    String.build(estimated_size) do |output|
      begin_text = true
      @text.split("\n").each { |line|
        unless begin_text
          output << "\n"
        else
          begin_text = false
        end
        handle_line(output, line)
      }
    end
  end

  # Interprets and adds the line into the builder
  private def handle_line(b : String::Builder, str : String)
    return handle_line_quote(b, str) if str.starts_with? "    "
    return handle_line_code_tag(b, str) if str.starts_with? "```"
    return handle_line_code(b, str) if @code_line == true
    @cursor = 0
    while @cursor < str.size
      # First [
      if (link_begin = str.index('[', @cursor))
        # Second [
        if str[link_begin + 1] == '['
          render_internal_link(b, str, link_begin)
          # Not a second ], so pass to the next [
        else
          b << str[@cursor..link_begin + 1]
          @cursor = link_begin + 2
        end
        # No [ left
      else
        b << str[@cursor..-1]
        @cursor = str.size
      end
    end
  end

  private def handle_line_quote(b, str)
    b << str
  end

  private def handle_line_code_tag(b, str)
    b << str
    @code_line = !@code_line
  end

  private def handle_line_code(b, str)
    b << str
  end

  # Render an internal link into the builder
  private def render_internal_link(b : String::Builder, str : String, link_begin : Int32)
    text_begin = link_begin + 2
    # Search for the end (the content cannot contain ']' because it must be an "alnum" char)
    if (link_end = str.index(']', text_begin)) && str[link_end + 1] == ']'
      text_end = link_end - 1
      text = str[text_begin..text_end]
      b << str[@cursor..(link_begin - 1)] unless link_begin == 0
      title, url = @index.find(text, @page)
      b << '[' << title << "](" << url << ')'
      @cursor = link_end + 2
    else
      b << str[@cursor..-1]
      @cursor = str.size
    end
  end

  def self.to_markdown(input : String, page : Page, index : Page::Index) : String
    Markdown.new(input, page, index).build
  end

  # ```
  # Page::Markdown.to_html("Test of [[internal-link]]", current_page, index_of_internal_links)
  # ```
  def self.to_html(input : String, page : Page, index : Page::Index) : String
    ::Markdown.to_html to_markdown(input, page, index)
  end
end
