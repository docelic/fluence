class Wikicr::SFile
  getter name : String
  getter files : Array(SFile)

  def self.build(to_scan : String) : SFile
    dir_current = Dir.current
    Dir.cd to_scan

    all_files = Dir.entries(".")
    all_files.select! { |file| !(file =~ /^\./) }

    files = all_files.select { |file| !File.directory? file }.map { |file| SFile.new(file).as(SFile) }
    directories = all_files.select { |file| File.directory? file }.map { |file| SFile.new(file, SFile.build(file).files).as(SFile) }

    structure = SFile.new(to_scan, files + directories)

    Dir.cd dir_current
    structure
  end

  def initialize(@name, @files = [] of SFile)
  end

  def directory?
    !@files.empty?
  end
end
