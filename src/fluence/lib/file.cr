require "./errors"

# `File` is a representation of anything that can be accessed
# via some sort of an URL and has ACLs applying to it.

# It is used to associate path, url and data.
#
# Pages and Media are two primary uses. Originally, all of this was
# in the Page struct directly, but structs can only inherit from
# abstract structs, so `File` was created as an abstract base
# for both Page and Media.
#
# Is is can also jail!s the path into the *OPTIONS.basedir* to be sure that
# there is no attack by writing files outside of the directory where the pages
# must be stored.
abstract struct Fluence::File

	class AlreadyExist < Exception
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
    self.jail!
    ::File.read @path
  end

  # Renames the page without modifying the current Page object.
	# Returns the new Page object where only path, name, and url fields may be correct and/or initialized.
  def rename(user : Fluence::User, new_name, overwrite = false)
    self.jail!
    Dir.mkdir_p ::File.dirname new_name
		if Fluence::PAGES[new_name]?
			raise AlreadyExist.new "Old and new name are the same, renaming not possible."
		end
		new_file = Page.name_to_path new_name
		if ::File.exists?(new_file) && !overwrite
			raise AlreadyExist.new "Destination exists and overwriting was not requested."
		else
			::File.rename self.path, new_file
			files = [new_file]
			dir = directory
			# TODO instead of dir mv, this needs to be done by moving pages one by one.
			if dir && ::File.exists?(dir)
				new_dir = ::File.dirname new_file
				#::File.rename dir, new_dir
				files << dir
				files << new_dir
			end
			commit! user, "rename", other_files: files
		end
		# Get from Index at this point
		Fluence::Page.new new_name
  end

	# Renames the page, updates self, and returns self
	def rename!(user : Fluence::User, new_name, overwrite = false)
		new_page = rename user, new_name, overwrite
		self.path = new_page.path
		self.name = new_page.name
		self.url = new_page.url
		self
	end

  # Writes into the *file*, and commit.
  def write(user : Fluence::User, body)
    self.jail!
    Dir.mkdir_p self.directory
    ::File.write @path, body
    commit! user, exists? ? "update" : "create"
  end

  # Deletes the *file*, and commit
  def delete(user : Fluence::User)
    self.jail!
    ::File.delete @path
    commit! user, "delete"
  end

  # Checks if the *file* exists
  def exists?
    self.jail!
    ::File.exists? @path
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
