class Fluence::Page < Fluence::File
  module Media

    def self.media(name : String)
			Fluence::MEDIA[name].children1
    end
  end
end
