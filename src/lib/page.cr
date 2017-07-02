require "./errors"
require "./sfile"

# A Page is a file and an url part
# Is is used to jail files into the OPTIONS.basedir
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

  # verify if the file is in the current dir (avoid ../ etc.)
  def jail
    chroot = Wikicr::OPTIONS.basedir
    # TODO: consider security of ".git/"

    # the @file is already exanded (File.expand_path) in the constructor
    if chroot != @file[0..(chroot.size - 1)]
      raise Error403.new "Out of chroot (#{@file} on #{chroot})"
    end
    self
  end

  def dirname
    File.dirname self.file
  end

  def read
    self.jail
    File.read self.file
  end

  def write(body)
    self.jail
    Dir.mkdir_p self.dirname
    File.write self.file, body
  end

  def delete
    self.jail
    File.delete self.file
  end

  def exists?
    self.jail
    File.exists? self.file
  end
end
