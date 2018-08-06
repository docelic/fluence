require "yaml"

require "./index/entry"

struct Fluence::Page < Fluence::Accessible
	# An Index is an index of all wiki pages and their metadata.
  class Index < Lockable
    YAML.mapping(
      file: String,
      entries: Hash(String, Entry) # path, entry
    )

		# Initializes index. `@file` is path to YAML-formatted file with index data.
    def initialize(@file : String)
      @entries = {} of String => Entry
    end

    # Loads index contents from file, replacing any existing index content.
    def load!
      if File.exists?(@file) && (new_index = Index.read(@file) rescue nil)
        @entries = new_index.entries
        # @file = index.file
      else
        @entries = {} of String => Entry
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

    def [](page : Fluence::Page) : Index::Entry
      @entries[page.path]
    end

    def []?(page : Fluence::Page) : Index::Entry?
      @entries[page.path]?
    end

		#####

    # Add a new `Entry` into the index. This is a memory-only operation
		# and does not sync new contents to disk.
    def add(page : Fluence::Page)
      @entries[page.path] = Entry.new page, toc: true, index: self
      self
    end

    # Remove an `Entry` from the `Index` based on its path.
    def delete(page : Fluence::Page)
      @entries.delete page.path
      self
    end

		#####

    # Find a matching *text* in the Index.
    # If no matching content, return a default value.
    def find(text : String, context : Page) : {String, String}
      found = find_by_title text, context
      return {found.title, found.url} unless found.nil?
      {text, "#{context.real_url_dirname}/#{Entry.title_to_slug text}"}
    end

    # Find the closest `Index`' `Entry` to *text* based on the entries title
    # and searching for the closer url as possible to the context
    private def find_by_title(text : String, context : Page) : Entry?
      # exact_matched = @entries.select{|_, entry| entry.title == text }.values
      # return choose_closer_url(exact_matched, context) unless exact_matched.empty?
      slug_matched = @entries.select { |_, entry| entry.slug == Index::Entry.title_to_slug(text) }.values
      return choose_closer_url(slug_matched, context) unless slug_matched.empty?
      nil
    end

    # Find the url which is the closest as possible than the context url (start with the maxmimum common chars).
    private def choose_closer_url(entries : Array(Entry), context : Page) : Entry
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
