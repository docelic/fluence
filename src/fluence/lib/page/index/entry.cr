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
        internal_links: Page::InternalLinks::LinkList,
      )

      def initialize(page : Fluence::Page, toc : Bool = false, index : Fluence::Page::Index? = nil)
				@path = page.path
				@url = page.url
				@title = page.title
        @toc = toc ? Page::TableOfContent.toc(page) : Page::TableOfContent::Toc.new

				# We don't want to keep the whole content in memory, even though we
				# could since media is not part of page content, only links to it are.
				# TODO See if keeping everything in memory makes sense and/or to conditionally keep it.
				#@page = page

        #@internal_links = index ? Page::InternalLinks.links(indexI#) : Page::InternalLinks::LinkList.new
        @internal_links = Page::InternalLinks::LinkList.new

        @slug = Entry.title_to_slug @title
      end

      def self.title_to_slug(title : String) : String
        title.gsub(/[^[:alnum:]^\/]/, "-").gsub(/-+/, '-').downcase
      end
    end
  end
end
