class MediaController < ApplicationController
  # get /mediamap
  def sitemap
    acl_permit! :read
    media = Fluence::FileTree.build Fluence::Media.subdirectory
    title = "Mediamap - #{title()}"
    render "sitemap.slang"
  end

  # get /media/search?q=
  def search
    query = params.query["q"]
    media = Fluence::Media.new(query)
    # TODO: a real search
    title = "Search Results - #{title()}"
    redirect_to query.empty? ? "/pages/home" : media.real_url
  end

  # get /media/*path
  def show
    acl_permit! :read
    flash["danger"] = params.query["flash.danger"] if params.query["flash.danger"]?
    pp params.url
    media = Fluence::Media.new url: params.url["path"], read_title: true
#    if (params.query["edit"]?) || !media.exists?
#      show_edit(media)
#    else
      show_show(media)
#    end
  end

  private def show_show(media)
    body = media.read rescue ""
    Fluence::ACL.load!

		if !media.exists?
			flash["info"] = "The media #{media.url} does not exist yet."
		end

    groups_read = Fluence::ACL.groups_having_any_access_to media.real_url, Acl::Perm::Read, true
    groups_write = Fluence::ACL.groups_having_any_access_to media.real_url, Acl::Perm::Write, true

		# TODO: Send media file to client
  end

  # post /media/*path
  def update
    acl_permit! :write
    media = Fluence::Media.new url: params.url["path"], read_title: true
    if params.body["rename"]?
      update_rename(media)
    elsif params.body["delete"]?
      update_delete(media)
    else
      update_edit(media)
    end
  end

	# post /media/upload
	def upload
		acl_permit! :write
		HTTP::FormData.parse(@env.request) do |file|
			filename = file.filename

			if !filename.is_a?(String)
				"No filename included in upload"
			else
				#file_path = ::File.join [Kemal.config.public_folder, "uploads/", filename]
				#File.open(file_path, "w") do |f|
				#IO.copy(file.tmpfile, f)
			end
		end
		@env.response.content_type = "application/json"
		{success: true}.to_json
	end

	# NOTE: Renaming a media can both rename and reattach to different page
  private def update_rename(media)
		page = Fluence::Page.new(media.real_url, true)
    if !params.body["new_path"]?.to_s.strip.empty?
      # TODO: verify if the user can write on new_path
      # TODO: if new_path do not begin with /, relative rename to the current path
      begin
        media.rename current_user, params.body["new_path"], !!params.body["new_path_overwrite"]?
        flash["success"] = "The media #{media.url} has been moved to #{params.body["new_path"]}."
        remove_empty_directories media
        redirect_to "/pages/#{params.body["new_path"]}"
      rescue e : Fluence::Media::AlreadyExist
        flash["danger"] = e.to_s
        redirect_to page.real_url
      end
    else
      redirect_to page.real_url
    end
  end

  private def update_delete(media)
			page = Fluence::Page.new(media.real_url, true)
#      Fluence::INDEX.transaction! { |index| index.delete media }
      media.delete current_user
      flash["success"] = "The media #{media.url} has been deleted."
      remove_empty_directories media
      redirect_to page.real_url
    rescue err
#      # TODO: what if the media is not deleted but not indexed anymore ?
#      # Fluence::INDEX.transaction! { |index| index.add media }
      flash["danger"] = "Error: cannot remove #{media.url}, #{err.message}"
      redirect_to page.real_url if page
  end

  private def update_edit(media)
			page = Fluence::Page.new(media.real_url, true)
      media.write current_user, params.body["body"]
#      media.read_title!
#      Fluence::INDEX.transaction! { |index| index.add media }
      flash["success"] = "The media #{media.url} has been updated."
      redirect_to page.real_url
    rescue err
      flash["danger"] = "Error: cannot update #{media.url}, #{err.message}"
      redirect_to page.real_url if page
  end

  private def remove_empty_directories(media : Fluence::Media)
    media_dir_elements = File.dirname(media.path).split File::SEPARATOR
    base_dir_elements = Fluence::Media.subdirectory.split File::SEPARATOR
    while media_dir_elements.size != base_dir_elements.size
      dir_path = media_dir_elements.join(File::SEPARATOR)
      if Dir.empty? dir_path
        Dir.rmdir dir_path
        media_dir_elements.pop
      else
        break
      end
    end
  end
end
