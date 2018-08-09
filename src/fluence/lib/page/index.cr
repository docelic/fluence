require "yaml"

struct Fluence::Page < Fluence::Accessible
	# Index is an index of all wiki pages and their metadata.
  class Index < Lockable
    YAML.mapping(
      file: String,
      entries: Hash(String, Page) # path, entry
    )

		# Initializes index. `@file` is path to YAML-formatted file with index data.
    def initialize(@file : String)
      @entries = {} of String => Page
    end

		def self.build(subdir : String, max_depth : Int = 1000) : Index
			idx = Index.new "meta/#{subdir}"
			files = file_list("data/#{subdir}", max_depth).each do |f|
				page = Fluence::Page.new f
				idx.add page
			end
			idx.save!
		end

		# Builds an array of wiki pages
		def self.file_list(to_scan : String, max_depth : Int = 1000) : Array
			# Stop the recursion
			raise Exception.new "Max recursion depth reached (#{max_depth})" if max_depth < 1

			# Save the current directory before getting in
			dir_current = Dir.current
			Dir.cd to_scan

			# List the files and filter them
			all_files = Dir.glob "*"

			# Separate files and directory
			files = all_files.select { |file| !File.directory? file }.map{ |f| f.chomp(".md")}

			# For the directories, call this function recursively
			directories = all_files
				.select { |file| File.directory? file }
				.map { |dir| Page::Index.file_list(dir, max_depth - 1).as(Array(String)).map { |f| File.join dir, f } }
				.each do |file_list|
					files += file_list
			end

			# Get out of the parent and return to current directory
			Dir.cd dir_current

			files
		end

    # Loads index contents from file, replacing any existing index content.
    def load!
      if File.exists?(@file) && (new_index = Index.read(@file) rescue nil)
        @entries = new_index.entries
        # @file = index.file
      else
        @entries = {} of String => Page
      end
      self
    end

		# Creates index object with contents from index file
    def self.read(file : String)
      Index.from_yaml File.read(file)
    end

    # Saves current index to file, replacing any existing on-disk contents.
    def save!
      File.write @file, self.to_yaml
      self
    end

    def [](page : Fluence::Page) : Fluence::Page
      @entries[page.path]
    end

    def []?(page : Fluence::Page) : Fluence::Page?
      @entries[page.path]?
    end

		#####

    # Adds a new `Page` into the index. This is a memory-only operation
		# and does not sync new contents to disk.
    def add(page : Fluence::Page)
      @entries[page.path] = Page.new page.url
      self
    end

    # Adds a new `Page` into the index. This operation
		# syncs new contents to disk.
		def add!(page)
			add page
			save!
			self
		end

    # Removes `Page` from `Index`. This is a memory-only operation
		# and does not sync new contents to disk.
    def delete(page : Fluence::Page)
      @entries.delete page.path
      self
    end

    # Renames `Page` in index. This is a memory-only operation
		# and does not sync new contents to disk.
		# TODO: modify page data, not just path (modify page's path and url, and/or real_url)
    def rename(page : Fluence::Page, new_page : Fluence::Page)
      @entries[new_page.path] = @entries.delete(page.path).not_nil!
      self
    end

		#####

    # Find a matching *text* in the Index.
    # If no matching content, return a default value.
    def find(text : String, context : Page) : {String, String}
      found = find_by_title text, context
      return {found.title, found.url} unless found.nil?
      {text, "#{context.real_url_dirname}/#{Page.title_to_slug text}"}
    end

    # Find the closest `Index`' `Page` to *text* based on the entries title
    # and searching for the closer url as possible to the context
    private def find_by_title(text : String, context : Page) : Page?
      # exact_matched = @entries.select{|_, entry| entry.title == text }.values
      # return choose_closer_url(exact_matched, context) unless exact_matched.empty?
      slug_matched = @entries.select { |_, entry| entry.slug == Fluence::Page.title_to_slug(text) }.values
      return choose_closer_url(slug_matched, context) unless slug_matched.empty?
      nil
    end

    # Find the url which is the closest as possible than the context url (start with the maxmimum common chars).
    private def choose_closer_url(entries : Array(Page), context : Page) : Page
      raise "Cannot handle empty array" if entries.empty?
      entries.reduce { |lhs, rhs| Index.url_closeness(context.url, lhs.url) >= Index.url_closeness(context.url, rhs.url) ? lhs : rhs }
    end

    # Computes the amount of common chars at the beginning of each string
    def self.url_closeness(from : String, to : String)
      from.size.times do |i|
        return i if from[i] != to[i]
      end
      return from.size
    end
  end
end
