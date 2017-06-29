module Wikicr
  class Error < Exception; end

  class Error404 < Error; end

  class Error403 < Error; end

  class SFile
    getter name : String
    getter files : Array(SFile)

    def initialize(@name, @files = [] of SFile)
    end

    def directory?
      !@files.empty?
    end
  end

  module Page
    extend self

    def file(name : String)
      real_file = name + ".md"
      real_file
    end

    # verify if the file is in the current dir (avoid ../ etc.)
    def jail(file : String, basedir : String? = nil) : String
      chroot = basedir || Wikicr::OPTIONS.basedir
      # TODO: consider security of ".git/"
      rfile = File.expand_path(file =~ /\.md$/ ? file : Page.file(file), Wikicr::OPTIONS.basedir)
      raise Error403.new "Out of chroot (#{rfile} on #{chroot})" if chroot != rfile[0..(chroot.size - 1)]
      rfile
    end

    def list(basedir : String? = nil)
      basedir ||= Wikicr::OPTIONS.basedir
      list_pages_in(basedir)
    end

    def list_pages_in(to_scan : String) : SFile
      dir_current = Dir.current
      Dir.cd to_scan

      all_files = Dir.entries(".")
      all_files.select! { |file| !(file =~ /^\./) }

      files = all_files.select { |file| !File.directory? file }.map { |file| SFile.new(file).as(SFile) }
      directories = all_files.select { |file| File.directory? file }.map { |file| SFile.new(file, list_pages_in(file).files).as(SFile) }

      structure = SFile.new(to_scan, files + directories)

      Dir.cd dir_current
      structure
    end
  end
end
