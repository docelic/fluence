# `FileTree` is structure representing a file with a name and subfiles.
# It is used to map the wiki for the "sitemap" feature.
# Also, it is used to populate Index when the index does not exist yet,
# or when index rebuild is requested.
# TODO: it should be fully replaced by the index
class Fluence::FileTree
  property name : String
  getter files : Array(FileTree)

  # Builds a FileTree that represents the real structure of the "to_scan"
  # It is recursive and may be very time consuming, so there is a depth limit.
  #
  # ```
  # FileTree.build("./data/")
  #
	# or:
  #
  # FileTree.build("./data/pages/")
  # FileTree.build("./data/media/")
  # ```
  def self.build(to_scan : String, max_depth : Int = 32) : FileTree
    # Stop the recursion
    return FileTree.new to_scan if max_depth < 1

    # Save the current directory before getting in
    dir_current = Dir.current
    Dir.cd to_scan

    # List the files, and filter them
    all_files = Dir.entries "."
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

		directories.each do |d|
			if f = files.find { |f2| f2.name == "#{d.name}.md" }
				d.name += ".md"
				files.delete f
			end
		end
		files += directories

    # Generate list of files and directories
    structure = FileTree.new to_scan, files

    # Get out of the parent and return to current directory
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
