require "uri"

require "./errors"

# `Accessible` is a representation of anything that can be accessed
# via some sort of an URL and has ACLs applying to it.

# It is used to associate path, url and data.
#
# Pages and Media are two primary uses. Originally, all of this was
# in the Page struct directly, but structs can only inherit from
# abstract structs, so `Accessible` was created as an abstract base
# for both Page and Media.
#
# Is is can also jails the path into the *OPTIONS.basedir* to be sure that
# there is no attack by writing files outside of the directory where the pages
# must be stored.
abstract struct Fluence::Accessible

	class AlreadyExist < Exception
	end

  # Path of the file that contains the page
  getter path : String

  # Url of the page (without any prefix)
  getter url : String

  # Complete Url of the page
  getter real_url : String

  # Title of the page
  getter title : String

	abstract def url_prefix : String

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
		@toc =  Page::TableOfContent::Toc.new
		@internal_links = Page::InternalLinks::LinkList.new
  end

  # translate a name ("/test/title" for example)
  # into a file path ("/srv/data/test/ttle.md)
  def self.url_to_file(url : String)
    page_dir = File.expand_path subdirectory
    page_file = File.expand_path Page.sanitize(url), page_dir
    page_file + ".md"
  end

  # verify if the *file* is in the current dir (avoid ../ etc.)
  # it will raise a `Error403` if the file is out of the basedir
  def jail
    # TODO: consider security of ".git/"

    # the @file is already expanded (File.expand_path) in the constructor
    if self.class.subdirectory != @path[0..(self.class.subdirectory.size - 1)]
      raise Error403.new "Out of chroot (#{@path} on #{self.class.subdirectory})"
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

  # Move the current page into another place and commit
  def rename(user : Fluence::User, new_url, overwrite = false)
    self.jail
    new_page = Fluence::Page.new new_url
    new_page.jail
    Dir.mkdir_p File.dirname new_page.path
		if new_page.path == path
			raise AlreadyExist.new "Old and new name are the same, renaming not possible."
		end
		if File.exists?(new_page.path) && !overwrite
			raise AlreadyExist.new "Destination exists and overwriting was not requested."
		else
			File.rename self.path, new_page.path
			commit! user, "rename", other_files: [new_page.path]
		end
		new_page.url
  end

  # Writes into the *file*, and commit.
  def write(user : Fluence::User, body)
    self.jail
    Dir.mkdir_p self.dirname
    is_new = File.exists? @path
    File.write @path, body
    commit! user, is_new ? "create" : "update"
  end

  # Deletes the *file*, and commit
  def delete(user : Fluence::User)
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
  def commit!(user : Fluence::User, message, other_files : Array(String) = [] of String)
    dir = Dir.current
    begin
      Dir.cd Fluence::OPTIONS.basedir
      puts `git add -- #{@path}`
      puts `git commit --no-gpg-sign --author \"#{user.name} <#{user.name}@localhost>\" -m \"#{message} #{@url}\" -- #{@path} #{other_files.join(" ")}`
    ensure
      Dir.cd dir
    end
  end
end
