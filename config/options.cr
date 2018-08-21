module Fluence
  class Options
    def initialize

			@brand = "Fluence"
			@brand_info = "#{@brand} - Fluence Wiki"
			@brand_logo = "/logo.png"

      @datadir = ::File.expand_path ENV.fetch("FLUENCE_DATADIR", "data"), Dir.current
      @metadir = ::File.expand_path ENV.fetch("FLUENCE_METADIR", "meta"), Dir.current

			@pages_prefix = "/pages"
			@homepage = ::File.join @pages_prefix, "home"

			@media_prefix = "/media"

			@users_prefix = "/users"

			@admin_prefix = "/admin"

			@recursion_limit = 1000

			@open_in_edit = false
			@open_new_in_edit = true
			@open_empty_in_edit = false

      Dir.mkdir_p @datadir
      Dir.mkdir_p @metadir
    end

    getter brand : String
    getter brand_info : String
    getter brand_logo : String
    getter datadir : String
    getter metadir : String
    getter homepage : String
    getter pages_prefix : String
    getter media_prefix : String
    getter users_prefix : String
    getter admin_prefix : String
    getter recursion_limit : Int32
    getter open_in_edit : Bool
    getter open_new_in_edit : Bool
    getter open_empty_in_edit : Bool
  end

  OPTIONS = Fluence::Options.new
end
