require "uri"

require "./errors"
require "./page/*"

# A `Page` is the representation in the wiki of something that can be accessed
# from an url /pages/*path.
#
# It is used to associate path, url and data.
# Is is can also jails the path into the *OPTIONS.basedir* to be sure that
# there is no attack by writing files outside of the directory where the pages
# must be stored.
struct Wikicr::Page
  include Wikicr::Page::TableOfContent

  # Directory where the pages are stored
  PAGES_SUB_DIRECTORY = "pages/"

  # Beginning of the url of a page
  URL_PREFIX = "/pages"

  # Path of the file that contains the page
  getter path : String

  # Url of the page (without any prefix)
  getter url : String

  # Complete Url of the page
  getter real_url : String

  # Title of the page
  getter title : String

  def initialize(url : String, real_url : Bool = false, read_title : Bool = false)
    if real_url
      @real_url = Page.sanitize_url url
      @url = @real_url[URL_PREFIX.size..-1]
    else
      @url = Page.sanitize_url url
      @real_url = File.expand_path @url, URL_PREFIX
    end
    @path = Page.url_to_file @url
    @title = File.basename @url
    @title = Page.read_title(@path) || @title if read_title && File.exists?(@path)
  end

  def self.read_title(path : String) : String?
    title = File.read(path).split("\n").find { |l| l.starts_with? "# " }
    title && title.strip("# ").strip
  end

  def self.sanitize_url(url : String)
    URI.unescape(url).gsub(/[^[:alnum:]\/]/, '-').gsub(/-+/, '-').downcase
  end

  def read_title!
    @title = Page.read_title(@path) || @title if File.exists?(@path)
  end

  # translate a name ("/test/title" for example)
  # into a file path ("/srv/data/test/ttle.md)
  def self.url_to_file(url : String)
    page_dir = File.expand_path Wikicr::OPTIONS.basedir, PAGES_SUB_DIRECTORY
    page_file = File.expand_path Page.sanitize_url(url), page_dir
    page_file + ".md"
  end

  # verify if the *file* is in the current dir (avoid ../ etc.)
  # it will raise a `Error403` if the file is out of the basedir
  def jail
    # TODO: consider security of ".git/"

    # the @file is already expanded (File.expand_path) in the constructor
    if Wikicr::OPTIONS.basedir != @path[0..(Wikicr::OPTIONS.basedir.size - 1)]
      raise Error403.new "Out of chroot (#{@path} on #{Wikicr::OPTIONS.basedir})"
    end
    self
  end

  # Get the directory of the *file* (~/data/test/home becomes ~/data/test)
  def dirname
    File.dirname @path
  end

  # Url without the page itself (/pages/test/home becomes /pages/test)
  def url_dirname
    File.dirname @url
  end

  # Real url without the page itself (/test/home becomes /test)
  def real_url_dirname
    File.dirname @real_url
  end

  # Reads the *file* and returns the content.
  def read
    self.jail
    File.read @path
  end

  # TODO: verify if the new_page already exists
  # Move the current page into another place and commit
  def rename(user : Wikicr::User, new_url)
    self.jail
    new_page = Wikicr::Page.new new_url
    new_page.jail
    Dir.mkdir_p File.dirname(new_page.path)
    File.rename self.path, new_page.path
    commit! user, "rename", other_files: [new_page.path]
  end

  # Writes into the *file*, and commit.
  def write(user : Wikicr::User, body)
    self.jail
    Dir.mkdir_p self.dirname
    is_new = File.exists? @path
    File.write @path, body
    commit! user, is_new ? "create" : "update"
  end

  # Deletes the *file*, and commit
  def delete(user : Wikicr::User)
    self.jail
    File.delete @path
    commit! user, "delete"
  end

  # Checks if the *file* exists
  def exists?
    self.jail
    File.exists? @path
  end

  # Save the modifications on the *file* into the git repository
  # TODO: lock before commit
  # TODO: security of jailed_file and self.name ?
  def commit!(user : Wikicr::User, message, other_files : Array(String) = [] of String)
    dir = Dir.current
    begin
      Dir.cd Wikicr::OPTIONS.basedir
      puts `git add -- #{@path}`
      puts `git commit --no-gpg-sign --author \"#{user.name} <#{user.name}@localhost>\" -m \"#{message} #{@url}\" -- #{@path} #{other_files.join(" ")}`
    ensure
      Dir.cd dir
    end
  end
end

# require "./users"
# require "./git"
# Wikicr::Page.new("testX").write("OK", Wikicr::USERS.load!.find("arthur.poulet@mailoo.org"))
