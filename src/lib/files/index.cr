require "yaml"
require "./page"

class Wikicr::Page::Index < Lockable
  class Entry
    YAML.mapping(
      path: String,  # path of the file /srv/wiki/data/xxx
      url: String,   # real url of the page /pages/xxx
      title: String, # Any title
    )

    def initialize(@path, @url, @title)
    end
  end

  YAML.mapping(
    file: String,
    entries: Hash(String, Entry) # path, entry
  )

  # Add a new `Entry`.
  def add(page : Wikicr::Page)
    entries[page.path] = Entry.new page.path, page.url, page.title
    self
  end

  # Remove an `Entry` from the `Index` based on its path.
  def delete(page : Wikicr::Page)
    entries.delete page.path
    self
  end

  def initialize(@file : String)
    @entries = {} of String => Entry
  end

  # Replace the old Index using the state registrated into the *file*.
  def load!
    if File.exists?(@file) && (new_index = Index.read(@file) rescue nil)
      @entries = new_index.entries
      # @file = index.file
    else
      @entries = {} of String => Entry
    end
    self
  end

  def self.read(file : String)
    Index.from_yaml(File.read file)
  end

  # Save the current state into the file
  def save!
    File.write @file, self.to_yaml
    self
  end
end
