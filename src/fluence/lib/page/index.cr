require "yaml"

struct Fluence::Page < Fluence::File
	# Index is an index of all files in a chosen subdirectory and their saved or generated metadata.
	# The indexed subdirectories are usually `pages/` containing all Fluence Wiki pages, and `media/` containing all media/attachments associated with the individual pages.
  class Index < Lockable
    YAML.mapping(
      file: String,
			directory: String,
      entries: Hash(String, Page) # path, entry
    )

		# Creates an empty index.
		# `@subdir` is name of the subdirectory within `basedir` that needs to be indexed, and will almost always be "pages" or "media".
    def initialize(subdir : String)
			@file = ::File.expand_path subdir, "meta"
			@directory = ::File.expand_path subdir, Fluence::OPTIONS.basedir
      @entries = {} of String => Page
    end

		# Creates an empty index, populates it with contents from desired subdir based on file search, and saves index contents to YAML file for persistence.
		# If you want to load an existing YAML dump of an index instead of create an index anew, see `load!`.
		def self.build(subdir : String, max_depth : Int = 1000) : Index
			idx = Index.new subdir
			files = file_list(idx.directory, max_depth).each do |f|
				# 'f' is name from subdir onwards, e.g. 'home', 'home/test', etc.
				page = Fluence::Page.new(f).process
				idx.add page
			end
			idx.save!
		end

		# Recursively finds files in the chosen starting directory.
		# Default limit is a maximum of 1000 directories to enter and scan.
		def self.file_list(subdir : String, max_depth : Int = 1000) : Array
			# Stop the recursion
			raise Exception.new "Max recursion depth reached (#{max_depth})" if max_depth < 1

			# Save the current directory before getting in
			dir_current = Dir.current
			Dir.cd subdir

			# List the files and filter them
			all_files = Dir.glob "*"

			# Separate files and directory
			files = all_files.select { |file| !::File.directory? file }.map{ |f| f.chomp(".md")}

			# For directories, call this function recursively
			directories = all_files
				.select { |file| ::File.directory? file }
				.map { |dir| Page::Index.file_list(dir, max_depth - 1).as(Array(String)).map { |f| ::File.join dir, f } }
				.each do |file_list|
					files += file_list
			end

			# Get out of the parent and return to current directory
			Dir.cd dir_current

			files
		end

    # Loads index contents from file, replacing any existing index content.
		# This method is faster than `build`, but it will contain stale data if the indexed directories are modified manually.
		# In such cases, just re-start Fluence with a command line option to rebuild the index, or delete the index in the `meta/` subdirectory and restart Fluence.
    def load!
      if ::File.exists?(@file) && (new_index = Index.read(@file) rescue nil)
        @entries = new_index.entries
        # @file = index.file
      else
        @entries = {} of String => Page
      end
      self
    end

		# Creates index from contents of YAML file. This is a low level function and you should generally use `load!` instead.
    def self.read(file : String)
      Index.from_yaml ::File.read(file)
    end

    # Saves current index to file, replacing any existing on-disk contents.
    def save!
      ::File.write @file, self.to_yaml
      self
    end

		# Returns Page from index, raises if missing.
		# There is generally little use from sending a Page as argument to retrieve the same Page back, so this should be used just as a true-or-raise check for existence of pages.
    def [](page : Fluence::Page) : Fluence::Page
      @entries[page.name]
    end
		# Returns Page from index, raises if missing.
    def [](name : String) : Fluence::Page
      @entries[name]
    end

		# Returns Page from index, nil if missing.
		# There is generally little use from sending a Page as argument to retrieve the same Page back, so this should be used just as a true-or-nil check for existence of pages.
    def []?(page : Fluence::Page) : Fluence::Page?
      @entries[page.name]?
    end
		# Returns Page from index, nil if missing.
    def []?(name : String) : Fluence::Page?
      @entries[name]?
    end

    # Adds a new `Page` into the index. This is a memory-only operation and does not sync new index contents to disk.
		# Only index is affected, not the actual file.
    def add(page : Fluence::Page)
      @entries[page.name] = page
      self
    end
    # Adds a new `Page` into the index. This operation syncs new index contents to disk.
		def add!(page : Fluence::Page)
			add page
			save!
			self
		end

    # Removes a Page from Index. This is a memory-only operation and does not sync new index contents to disk.
		# Recursive deletion is not handled here for now.
    def delete(page : Fluence::Page)
      @entries.delete page.name
      self
    end
    # Deletes a page from index. This operation syncs new index contents to disk.
		# Recursive deletion is not handled here for now.
		def delete!(page : Fluence::Page)
			delete page
			save!
			self
		end

    # Renames `Page` in index. This is a memory-only operation and does not sync new contents to disk.
		# Recursive renaming is not handled here for now.
    def rename(page : Fluence::Page, new_name : String)
      @entries[new_name] = @entries.delete(page.name).not_nil!
      self
    end
    # Renames a page in index. This operation syncs new index contents to disk.
		# Recursive renaming is not handled here for now.
		def rename!(page : Fluence::Page)
			rename page
			save!
			self
		end

		# Returns all children of file
		def children(page : Fluence::Page)
			dir = page.directory
			@entries.select {|k,v| k =~ /^#{dir + ::File::SEPARATOR}/}
		end
		# Returns 1 level of children of file
		def children1(page : Fluence::Page)
			@entries.select {|k,v| k =~ /^#{page.name}\/[^\/]+$/}
		end

		# Returns all index chidlren (alias with `entries`)
		def children
			@entries
		end
		# Returns 1 level of children
		def children1
			@entries.select {|k,v| k =~ /^[^#{::File::SEPARATOR}]+$/}
		end

		#####
		# TODO review these functions below

    # Find a matching *text* in the Index.
    # If no matching content, return a default value.
    def find(text : String, context : Page) : {String, String}
      found = find_by_title text, context
      return {found.title, found.url} unless found.nil?
      {text, "#{context.directory}/#{Page.title_to_slug text}"}
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
