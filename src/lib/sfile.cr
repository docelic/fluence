# a SFile is a file structure with a name and subfiles
class Wikicr::SFile
  getter name : String
  getter files : Array(SFile)

  # Build a SFile that represents the real structure of the "to_scan"
  # It is recursive and may be very time consuming, so there is a limit of  depth
  def self.build(to_scan : String, max_depth : Int = 32) : SFile
    return SFile.new(to_scan) if max_depth < 1
    dir_current = Dir.current
    Dir.cd to_scan

    all_files = Dir.entries(".")
    all_files.select! { |file| !(file =~ /^\./) }

    files = all_files
      .select { |file| !File.directory? file }
      .map { |file| SFile.new(file).as(SFile) }
    directories = all_files
      .select { |file| File.directory? file }
      .map { |file| SFile.new(file, SFile.build(file, max_depth - 1).files).as(SFile) }

    structure = SFile.new(to_scan, files + directories)

    Dir.cd dir_current
    structure
  end

  def initialize(@name, @files = [] of SFile)
  end

  # if the file contains other files, then it is a "directory"
  def directory? : Bool
    !@files.empty?
  end
end
