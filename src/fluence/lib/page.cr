require "uri"

require "./accessible"
require "./errors"
require "./page/*"

# `Page` is a representation of something that can be accessed
# from a URL /pages/*path.
#
# It is used to associate path, url and data.
# Is is can also jails the path into the *OPTIONS.basedir* to be sure that
# there is no attack by writing files outside of the directory where the pages
# must be stored.
struct Fluence::Page < Fluence::Accessible
  include Fluence::Page::TableOfContent
  include Fluence::Page::InternalLinks

	YAML.mapping(
		path: String,  # path of the file /srv/wiki/data/xxx
		url: String,   # url of the page /pages/xxx
		real_url: String,   # real url of the page /pages/xxx
		title: String, # Any title
		slug: String,  # Exact matching title
		toc: Page::TableOfContent::Toc,
		internal_links: Page::InternalLinks::LinkList,
	)

	def initialize(url : String, real_url : Bool = false, read_title : Bool = false)
    url = Page.sanitize(url)
    if real_url
      @real_url = url
      @url = @real_url[url_prefix.size..-1].strip "/"
    else
      @url = url.strip "/"
      @real_url = File.expand_path @url, url_prefix
    end
    @path = Page.url_to_file @url
    @title = File.basename @url
    @title = Page.read_title(@path) || @title if read_title && File.exists? @path
    @slug = ""
    @toc = Page::TableOfContent::Toc.new
    @internal_links = Page::InternalLinks::LinkList.new
	end

  # Directory where the pages are stored
  def self.subdirectory
    File.join(Fluence::OPTIONS.basedir, "pages") + File::SEPARATOR
  end

  # Beginning of the URL
  def url_prefix
    "/pages"
  end

  def self.read_title(path : String) : String?
    title = File.read(path).split("\n").find { |l| l.starts_with? "# " }
    title && title.strip("# ").strip
  end

  def self.sanitize(url : String)
    title_to_slug URI.unescape(url)
  end

  def read_title!
    @title = Page.read_title(@path) || @title if File.exists?(@path)
  end

	def self.title_to_slug(title : String) : String
		title.gsub(/[^[:alnum:]^\/]/, "-").gsub(/-+/, '-').downcase
	end

  def self.remove_empty_directories(path)
    page_dir_elements = File.dirname(path).split File::SEPARATOR
    base_dir_elements = Fluence::Page.subdirectory.split File::SEPARATOR
    while page_dir_elements.size != base_dir_elements.size
      dir_path = page_dir_elements.join(File::SEPARATOR)
      if Dir.empty? dir_path
        Dir.rmdir dir_path
        page_dir_elements.pop
      else
        break
      end
    end
  end
end
