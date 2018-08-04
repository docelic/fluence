require "../table_of_content"
require "../internal_links"

# And Index is an object that associate a file with a lot of meta-data
# like related url, the title, the table of content, ...
struct Fluence::Page < Fluence::Accessible
  class Index < Lockable
    class Entry
      YAML.mapping(
        path: String,  # path of the file /srv/wiki/data/xxx
        url: String,   # real url of the page /pages/xxx
        title: String, # Any title
        slug: String,  # Exact matching title
        toc: Page::TableOfContent::Toc,
        intlinks: Page::InternalLinks::LinkList,
      )

      def initialize(@path, @url, @title, toc : Bool = false, intlinks : Tuple(Fluence::Page::Index, Fluence::Page)? = nil)
        @slug = Entry.title_to_slug title
        @toc = toc ? Page::TableOfContent.toc(@path) : Page::TableOfContent::Toc.new
        @intlinks = intlinks ? Page::InternalLinks.links(@path, *intlinks) : Page::InternalLinks::LinkList.new
      end

      def self.title_to_slug(title : String) : String
        title.gsub(/[^[:alnum:]^\/]/, "-").gsub(/-+/, '-').downcase
      end
    end
  end
end
