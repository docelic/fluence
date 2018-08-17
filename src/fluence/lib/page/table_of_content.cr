require "../file"
struct Fluence::Page < Fluence::File
  module TableOfContent
    alias TocLine = {Int32, String}
    alias Toc = Array(TocLine)

    # The table of content of the file
    def toc : Toc
      TableOfContent.toc @path
    end

    def self.toc(page : Fluence::Page) : Toc
			toc page.path
		end
    def self.toc(path : String) : Toc
      toc = Toc.new
      ::File.open path, "r" do |f|

				code_block = false

        while line = f.gets
					if line =~ /^```/
						code_block = !code_block
					end

					next if code_block

          toc_line = get_toc_line line
          toc << toc_line.as(TocLine) unless toc_line.nil?
        end
      end
      #pp toc
      toc
    end

    # Parse a markdown line, and return a TocLine if it is a title
    def self.get_toc_line(line : String) : TocLine?
      if match = line.match /^(\#{1,6})\s(.+)/
        title_num = match[1].size
        title = match[2]
        {title_num, title}
      end
    end
  end
end
