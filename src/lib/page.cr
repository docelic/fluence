require "./errors"
require "./sfile"

# A `Page` is a file and an url part
# Is is used to jail files into the *OPTIONS.basedir*
struct Wikicr::Page
  getter file : String
  getter name : String

  def initialize(@name)
    @file = Page.name_to_file(@name)
  end

  # translate a name ("/test/title" for example)
  # into a file path ("/srv/data/test/ttle.md)
  def self.name_to_file(name : String)
    File.expand_path(name + ".md", Wikicr::OPTIONS.basedir)
  end

  # :unused:
  # # translate a file into a name
  # # @see #name_to_file
  # def self.file_to_name(file : String)
  #   file.chomp(".md")[Wikicr::OPTIONS.basedir.size..-1]
  # end

  # :unused:
  # # set a new file name, an update the file path
  # def name=(name)
  #   @name = name
  #   @file = Page.name_to_file @name
  # end

  # :unused:
  # # set a new file path, and update the file name
  # def file=(file)
  #   @file = File.expand_path file
  #   @name = Page.file_to_name @file
  # end

  # verify if the *file* is in the current dir (avoid ../ etc.)
  # it will raise a `Error403` if the file is not accessible to the user
  def jail(user : User)
    # TODO: consider security of ".git/"
    # TODO: read ACL for user

    # the @file is already expanded (File.expand_path) in the constructor
    if Wikicr::OPTIONS.basedir != @file[0..(Wikicr::OPTIONS.basedir.size - 1)]
      raise Error403.new "Out of chroot (#{@file} on #{Wikicr::OPTIONS.basedir})"
    end
    self
  end

  private def jailed_file(user)
    @file[Wikicr::OPTIONS.basedir.size..-1].strip("/")
  end

  # Get the directory of the *file*
  def dirname
    File.dirname self.file
  end

  # Reads the *file*
  def read(user : User)
    self.jail user
    File.read self.file
  end

  # Writes into the *file*, and commit
  def write(body, user : User)
    self.jail user
    Dir.mkdir_p self.dirname
    is_new = File.exists? self.file
    File.write self.file, body
    commit!(user, is_new ? "create" : "update")
  end

  # Deletes the *file*, and commit
  def delete(user : User)
    self.jail user
    File.delete self.file
    commit!(user, "delete")
  end

  # Checks if the *file* exists
  def exists?(user : User)
    self.jail user
    File.exists? self.file
  end

  # Save the modifications on the *file* into the git repository
  def commit!(user, message)
    # TODO: lock before commit
    # TODO: security of jailed_file and self.name ?
    dir = Dir.current
    Dir.cd Wikicr::OPTIONS.basedir
    puts `git add -- #{jailed_file(user)}`
    puts `git commit -s --author \"#{user.name}\" -m \"#{message} #{self.name}\" -- #{jailed_file(user)}`
    Dir.cd dir
  end
end

# require "./users"
# require "./git"
# Wikicr::Page.new("testX").write("OK", Wikicr::USERS.read!.find("arthur.poulet@mailoo.org"))
