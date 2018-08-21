require "uri"

require "./file"
require "./errors"
require "./page/*"

# `Page` is a representation of something that can be accessed
# from a URL /pages/*path.
#
# It is used to associate path, name (and URL), and data.
# Is is can also jails the path into the *OPTIONS.datadir* to be sure that
# there is no attack by writing files outside of the directory where the pages
# must be stored.
class Fluence::Page < Fluence::File

# Disabled for now due to:
# https://github.com/crystal-lang/crystal/issues/2827
#  include Fluence::Page::TableOfContent
#  include Fluence::Page::InternalLinks

	YAML.mapping(
		path: String,  # absolute path of the file, e.g. /srv/wiki/data/pages/xxx
		name: String,   # name of the page, e.g. xxx or xxx/subpage1
		url: String,   # real url of the page /pages/xxx
		title: String, # Any title
		slug: String,  # URL-friendly title
		toc: Page::TableOfContent::Toc,
		intlinks: Page::InternalLinks::LinkList,
		modification_time: Time
	)

	def initialize(name : String)
    name = Page.sanitize(name).strip "/"
		url = url_prefix + "/" + name
    path = Page.name_to_directory(name)+ ".md"

		# Needed due to https://github.com/crystal-lang/crystal/issues/2827
		title = ::File.basename name
		super(path,name,url,title)

		@slug = Page.title_to_slug @title
		@intlinks = Page::InternalLinks::LinkList.new
		@toc = Page::TableOfContent::Toc.new

		# This data will be inaccurate (i.e. be current time) if an existing page
		# is created with Fluence::Page.new("existing_name") and #process! is not called.
		@modification_time = Time.new
	end

	def process!
		# TODO read all this from one copy of contents
    title = ::File.read(@path).split("\n").find { |l| l.starts_with? "# " }
    @title = if title; title.strip("# ").strip else @name.sub /^.+\//, "" end
		@slug = Page.title_to_slug @title
		@toc = Page::TableOfContent.toc @path
		@intlinks = Page::InternalLinks.intlinks @path
		@modification_time = ::File.info(@path).modification_time
		self
	end

	def exists?
		::File.exists? @path
	end

  # Directory where the pages are stored
  def self.subdirectory
    ::File.join(Fluence::OPTIONS.datadir, "pages") + ::File::SEPARATOR
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
    page_dir_elements = ::File.dirname(path).split ::File::SEPARATOR
    base_dir_elements = Fluence::Page.subdirectory.split ::File::SEPARATOR
    while page_dir_elements.size != base_dir_elements.size
      dir_path = page_dir_elements.join(::File::SEPARATOR)
      if Dir.empty? dir_path
        Dir.rmdir dir_path
        page_dir_elements.pop
      else
        break
      end
    end
  end

	def children1
		Fluence::PAGES.children1 self
	end

	def children
		Fluence::PAGES.children self
	end
end
