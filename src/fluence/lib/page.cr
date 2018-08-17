require "uri"

require "./accessible"
require "./errors"
require "./page/*"

# `Page` is a representation of something that can be accessed
# from a URL /pages/*path.
#
# It is used to associate path, name (and URL), and data.
# Is is can also jails the path into the *OPTIONS.basedir* to be sure that
# there is no attack by writing files outside of the directory where the pages
# must be stored.
struct Fluence::Page < Fluence::Accessible
  include Fluence::Page::TableOfContent
  include Fluence::Page::InternalLinks

	YAML.mapping(
		path: String,  # absolute path of the file, e.g. /srv/wiki/data/pages/xxx
		name: String,   # name of the page, e.g. xxx or xxx/subpage1
		url: String,   # real url of the page /pages/xxx
		title: String, # Any title
		slug: String,  # URL-friendly title
		toc: Page::TableOfContent::Toc,
		intlinks: Page::InternalLinks::LinkList,
	)

	def initialize(name : String, process : Bool = true, is_url : Bool = false)
    name = Page.sanitize(name)
    if is_url
      @url = name
      @name = @url[url_prefix.size..-1].strip "/"
    else
      @name = name.strip "/"
      @url = url_prefix + "/" + name
    end
    @path = Page.name_to_directory @name
		@title = nil

		if process && exists?
			@title, @toc, @intlinks = Page.process(@path)
		else
			@toc = Page::TableOfContent::Toc.new
			@intlinks = Page::InternalLinks::LinkList.new
		end

		@title ||= File.basename @name
		@slug = Page.title_to_slug @title
	end

	def process(path)
    title = File.read(path).split("\n").find { |l| l.starts_with? "# " }
    title = if title; title.strip("# ").strip else nil end

		toc = toc path

		intlinks = intlinks path

		[title, toc, intlinks]
	end

	def exists?
		File.exists? @path
	end

  # Directory where the pages are stored
  def self.subdirectory
    File.join(Fluence::OPTIONS.basedir, "pages") + File::SEPARATOR
  end

  # Beginning of the URL
  def url_prefix
    "/pages"
  end

  def self.sanitize(text : String)
    title_to_slug URI.unescape(text)
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
