require "./errors"

# `File` is a representation of anything that can be accessed
# via some sort of an URL and has ACLs applying to it.

# It is used to associate path, url and data.
#
# Pages and Media are two primary uses. Originally, all of this was
# in the Page class directly, but class can only inherit from
# abstract class, so `File` was created as an abstract base
# for both Page and Media.
#
# Is is can also jail!s the path into the *OPTIONS.basedir* to be sure that
# there is no attack by writing files outside of the directory where the pages
# must be stored.
abstract class Fluence::File

	class AlreadyExists < Exception
	end

  # Path of the file that contains the page
  getter path : String

  # Url of the page (without any prefix)
  getter name : String

  # Complete Url of the page
  getter url : String

  # Title of the page
  getter title : String

	# Pointless initialize needed due to https://github.com/crystal-lang/crystal/issues/2827
	def initialize(@path,@name,@url,@title)
	end

	abstract def url_prefix : String

  # translates a name ("/test/title" for example)
  # into a file path ("/srv/data/test/title.md)
  def self.name_to_path(name : String)
    name_to_directory(name) + ".md"
  end

  # translate a name ("/test/title" for example)
  # into a directory path ("/srv/data/test/title)
  def self.name_to_directory(name : String)
    ::File.expand_path Page.sanitize(name), subdirectory
  end

  # verify if the *file* is in the current dir (avoid ../ etc.)
  # it will raise a `Error403` if the file is out of the basedir
  def jail!
    # TODO: consider security of ".git/"

    # the @file is already expanded (::File.expand_path) in the constructor
    if self.class.subdirectory != @path[0..(self.class.subdirectory.size - 1)]
      raise Error403.new "Out of chroot (#{@path} on #{self.class.subdirectory})"
    end
    self
  end

  # Reads the *file* and returns the content.
  def read
    jail!
    ::File.read @path
  end

  # Renames the page without modifying the current Page object.
	# Returns the new Page object where only path, name, and url fields may be correct and/or initialized.
  def rename(user : Fluence::User, new_name, overwrite = false, subtree = false, git = true)
    jail!
    Dir.mkdir_p ::File.dirname new_name
		if name == new_name
			raise AlreadyExists.new "Old and new name are the same, renaming not possible."
		end

		# Mostly disposable, here just to check jail.
		new_page = Page.new new_name
		new_page.jail!

		# TODO instead of raising, add flash message and skip
		# It would be sufficient to check the Index for existence of page,
		# but given that unintended deletions/overwrites of content can be
		# a problem, test in a more certain way by testing file existence.
		if ::File.exists?(new_page.path) && !overwrite
			raise AlreadyExists.new %Q(Destination exists and overwriting was not requested. Do you want to visit the page #{new_page.name} instead?)
		else
			Dir.mkdir_p ::File.dirname new_page.path
			::File.rename path, new_page.path
			files = [new_page.path]

			if git
				commit! user, "rename", other_files: files
			end
		end
		# Get from Index at this point
		Fluence::Page.new new_name
  end

	# Renames the page, updates self, and returns self
	def rename!(user : Fluence::User, new_name, overwrite = false, subtree = false, git = true)
		new_page = rename user, new_name, overwrite, subtree, git
		@path = new_page.path
		@name = new_page.name
		@url = new_page.url
		jail!
		process!
		self
	end

	def update!(user : Fluence::User, body)
		write user, body
		process!
		self
	end

  # Writes into the *file*, and commit.
  def write(user : Fluence::User, body)
    jail!
    Dir.mkdir_p self.directory
    ::File.write @path, body
    commit! user, exists? ? "update" : "create"
  end

  # Deletes the *file*, and commits
  def delete(user : Fluence::User)
    jail!
    ::File.delete @path
    commit! user, "delete"
		self
  end

  # Checks if the *file* exists
  def exists?
    jail!
    ret = ::File.exists? @path
		ret
  end
	
	def directory
		@path.chomp ".md"
	end

	def parent_directory
		::File.dirname @path
	end

	def directory?
		::File.exists? directory
	end

  # Save the modifications on the *file* into the git repository
  # TODO: lock before commit
  # TODO: security of jail!ed_file and self.name ?
  def commit!(user : Fluence::User, message, other_files : Array(String) = [] of String)
    dir = Dir.current
    begin
      Dir.cd Fluence::OPTIONS.basedir
			all_files = @path + " " + other_files.join(" ")
      puts `git add -- #{all_files}`
      puts `git commit --no-gpg-sign --author \"#{user.name} <#{user.name}@localhost>\" -m \"#{message} #{@name}\" -- #{all_files}`
    ensure
      Dir.cd dir
    end
  end
end
