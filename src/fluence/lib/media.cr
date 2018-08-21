require "uri"

require "./errors"
require "./page/*"

# `Media` is a representation of something that can be accessed
# from a URL /media/*path.
#
# As much as possible here should come from Fluence::File.
class Fluence::Media < Fluence::File

  # Directory where media is stored
  def self.subdirectory
		::File.join(Fluence::OPTIONS.datadir, "media") + ::File::SEPARATOR
	end

  # Beginning of the URL
	def url_prefix
		Fluence::OPTIONS.media_prefix
	end
end
