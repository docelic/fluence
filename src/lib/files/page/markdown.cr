struct Wikicr::Page::Markdown
  property text : String
  property index : Page::Index
  property page : Page
  @cursor : Int32

  def initialize(@text, @page, @index)
    @cursor = 0
  end

  # Build a new String which render a valid markdown from the wikimd
  def build : String
    estimated_size = (@text.size + @text.count("[") * 8)
    String.build(estimated_size) do |output|
      @text.split("\n").each { |line| handle_line(output, line); output << "\n" }
    end
  end

  # Interprets and adds the line into the builder
  private def handle_line(b : String::Builder, str : String)
    @cursor = 0
    while @cursor < str.size
      # First [
      if (link_begin = str.index('[', @cursor))
        # Second [
        if str[link_begin + 1] == '['
          render_internal_link(b, str, link_begin)
        # Not a second ], so pass to the next [
        else
          b << '['
          @cursor += 1
        end
      # No [ left
      else
        b << str[@cursor..-1]
        @cursor = str.size
      end
    end
  end

  # Render an internal link into the builder
  private def render_internal_link(b : String::Builder, str : String, link_begin : Int32)
    text_begin = link_begin + 2
    # Search for the end (the content cannot contain ']' because it must be an "alnum" char)
    if (link_end = str.index(']', text_begin)) && str[link_end + 1] == ']'
      text_end = link_end - 1
      text = str[text_begin..text_end]
      b << str[@cursor..(link_begin - 1)] unless link_begin == 0
      # TODO:#1 /pages/ is configurable
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
