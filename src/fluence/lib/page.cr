require "uri"

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

  # Directory where the pages are stored
  def self.subdirectory
    "pages/"
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
    Index::Entry.title_to_slug URI.unescape(url)
  end

  def read_title!
    @title = Page.read_title(@path) || @title if File.exists?(@path)
  end
end
