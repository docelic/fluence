# A `FileTree` is a tree structure representing a file with a name and subfiles.
class Wikicr::FileTree
  getter name : String
  getter files : Array(FileTree)

  # Build a FileTree that represents the real structure of the "to_scan"
  # It is recursive and may be very time consuming, so there is a limit of  depth
  #
  # ```
  # FileTree.build("./data/")
  # ```
  def self.build(to_scan : String, max_depth : Int = 32) : FileTree
    # Stop the recursion
    return FileTree.new(to_scan) if max_depth < 1

    # Save the current directory before getting in
    dir_current = Dir.current
    Dir.cd to_scan

    # List the files, and filter them
    all_files = Dir.entries(".")
    all_files.select! { |file| !(file =~ /^\./) }
    all_files.sort!

    # Separate files and directory
    # For the directories, call this function recursively
    files = all_files
      .select { |file| !File.directory? file }
      .map { |file| FileTree.new(file).as(FileTree) }
    directories = all_files
      .select { |file| File.directory? file }
      .map { |file| FileTree.new(file, FileTree.build(file, max_depth - 1).files).as(FileTree) }

    # Generate the file with the list of the files and the directories
    structure = FileTree.new(to_scan, files + directories)

    # Get out of the parent and return the current directory object
    Dir.cd dir_current
    structure
  end

  def initialize(@name, @files = [] of FileTree)
  end

  # If the file contains other files, then it is a "directory"
  def directory? : Bool
    !@files.empty?
  end
end
