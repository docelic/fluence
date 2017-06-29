module Wikicr
  class Error < Exception; end

  class Error404 < Error; end

  class Error403 < Error; end

  module Page
    def self.file(name : String)
      real_file = name + ".md"
      real_file
    end

    # verify if the file is in the current dir (avoid ../ etc.)
    def self.jail(file : String, basedir : String? = nil) : String
      chroot = basedir || Wikicr::OPTIONS.basedir
      # TODO: consider security of ".git/"
      rfile = File.expand_path(file =~ /\.md$/ ? file : Page.file(file), Wikicr::OPTIONS.basedir)
      raise Error403.new "Out of chroot (#{rfile} on #{chroot})" if chroot != rfile[0..(chroot.size - 1)]
      rfile
    end
  end
end
