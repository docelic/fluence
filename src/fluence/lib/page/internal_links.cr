struct Fluence::Page < Fluence::Accessible
  module InternalLinks
    # {id, page-real-url}
    alias Link = {Int32, String}
    alias LinkList = Array(Link)

    def internal_links(index_context : Fluence::Page::Index = Fluence::PAGES)
      InternalLinks.links @path, index_context, self
    end

    def self.links(path : String, index : Fluence::Page::Index, page : Fluence::Page)
      content = File.exists?(path) ? File.read path : ""
      links_in_content content, index, page
    end

    def self.links_in_content(content : String, index : Fluence::Page::Index, page : Fluence::Page)
      links = LinkList.new
      link_begin = -1
      while link_begin = content.index("[[", link_begin + 1)
        link_end = content.index "]]", link_begin
        next if link_end.nil?
        end_of_line = content.index '\n', link_begin
        next if end_of_line && end_of_line < link_end
        page_search_text = content[link_begin + 2..link_end - 1]
        links << get_link(link_begin + 2, page_search_text, index, page)
      end
      links
    end

    def self.get_link(begin_link_text, page_search_text, index, page) : Link
      _, u = index.find page_search_text, page
      {begin_link_text, u}
    end
  end
end
