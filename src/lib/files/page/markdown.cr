require "./markdown/*"
require "markd"

struct Wikicr::Page::Markdown
  include Markdown::Render

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
    @cursor = 0
    return render_title(b, str) if str.starts_with? '#'
    return render_quote(b, str) if str.starts_with? "    "
    return render_code_tag(b, str) if str.starts_with? "```"
    return render_code(b, str) if @code_line == true
    while @cursor < str.size
      if (link_begin = str.index('[', @cursor)) # First [
        if str[link_begin + 1] == '['           # Second [
          render_internal_link b, str, link_begin
        else # Not a second ], so pass to the next [
          render_partial_line b, str, link_begin + 1
        end
        # No [ left
      elsif (special_tag_begin = str.index('{', @cursor)) # First {
        if str[special_tag_begin + 1] == '{'              # Second {
          render_special_tag b, str, special_tag_begin
        else
          render_partial_line b, str, special_tag_begin + 1
        end
      else
        render_full_line b, str
      end
    end
  end

  def self.to_markdown(input : String, page : Page, index : Page::Index) : String
    Markdown.new(input, page, index).build
  end

  # ```
  # Page::Markdown.to_html("Test of [[internal-link]]", current_page, index_of_internal_links)
  # ```
  def self.to_html(input : String, page : Page, index : Page::Index) : String
    ::Markd.to_html to_markdown(input, page, index)
  end
end
