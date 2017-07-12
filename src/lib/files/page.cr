require "../errors"
require "./file_tree"

require "uri"

# A `Page` is a file and an url part
# Is is used to jail files into the *OPTIONS.basedir*
struct Wikicr::Page
  PAGES_SUB_DIRECTORY = "pages/"
  URL_PREFIX          = "/pages"

  getter path : String
  getter url : String
  getter title : String
  getter real_url : String

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
  # it will raise a `Error403` if the file is not accessible to the user
  def jail(user : User)
    # TODO: consider security of ".git/"
    # TODO: read Acl for user

    # the @file is already expanded (File.expand_path) in the constructor
    if Wikicr::OPTIONS.basedir != @path[0..(Wikicr::OPTIONS.basedir.size - 1)]
      raise Error403.new "Out of chroot (#{@path} on #{Wikicr::OPTIONS.basedir})"
    end
    self
  end

  # Get the directory of the *file*
  def dirname
    File.dirname @path
  end

  # Reads the *file*.
  def read(user : User)
    self.jail user
    File.read @path
  end

  # Writes into the *file*, and commit.
  def write(body, user : User)
    self.jail user
    Dir.mkdir_p self.dirname
    is_new = File.exists? @path
    File.write @path, body
    commit!(user, is_new ? "create" : "update")
  end

  # Deletes the *file*, and commit
  def delete(user : User)
    self.jail user
    File.delete @path
    commit!(user, "delete")
  end

  # Checks if the *file* exists
  def exists?(user : User)
    self.jail user
    File.exists? @path
  end

  # Save the modifications on the *file* into the git repository
  def commit!(user, message)
    # TODO: lock before commit
    # TODO: security of jailed_file and self.name ?
    dir = Dir.current
    Dir.cd Wikicr::OPTIONS.basedir
    puts `git add -- #{@path}`
    puts `git commit --no-gpg-sign --author \"#{user.name} <#{user.name}@localhost>\" -m \"#{message} #{@url}\" -- #{@path}`
    Dir.cd dir
  end
end

# require "./users"
# require "./git"
# Wikicr::Page.new("testX").write("OK", Wikicr::USERS.load!.find("arthur.poulet@mailoo.org"))
