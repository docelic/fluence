module Wikicr
  class Error < Exception; end

  class Error404 < Error; end

  class Error403 < Error; end

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
      list_pages_in(basedir).sort.map do |file|
        file = file[basedir.size..-1].strip("/").chomp(".md")
        {url: File.expand_path(file, "/pages/"), file: file}
      end
    end

    def list_pages_in(to_scan : String)
      to_scan_expanded = File.expand_path "*", to_scan
      all_files = Dir.glob to_scan_expanded
      all_files.select! { |file| !(file =~ /^\./) }
      all_files.map { |file| File.directory?(file) ? list_pages_in(file) : [file] }.flatten
    end
  end
end
