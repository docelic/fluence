class PagesController < ApplicationController
  # get /sitemap
  def sitemap
    acl_permit! :read
    #pages = Fluence::FileTree.build Fluence::Page.subdirectory
		#media = Fluence::FileTree.build Fluence::Media.subdirectory
    title = "Sitemap - #{title()}"
    #render "sitemap.slang"
  end

  # get /pages/search?q=
  def search
    #if query = params.query["q"]
		#	page = Fluence::Page.new(query.not_nil!)
		#	# TODO: a real search
		#end
		page = nil
    title = "Search Results - #{title()}"
    #redirect_to (query.empty? || !page) ? "/pages/home" : page.url
    redirect_to "/pages/home"
  end

  # get /pages/*path
  def show
    acl_permit! :read
    flash["danger"] = params.query["flash.danger"] if params.query["flash.danger"]?
		if page = Fluence::PAGES[params.url["path"]]?
			# Page exists in the index
		else
			page = Fluence::Page.new params.url["path"]
		end
		show_show(page)
  end

  private def show_show(page)
    body = page.read rescue ""
    body_html = body ? Fluence::Markdown.to_html body, page, Fluence::PAGES.load! : ""
    Fluence::ACL.load!

		if !page.exists?
			flash["info"] = "The page #{page.name} does not exist yet."
			flash["info"] += " You could create it by typing in and saving new content." if
				Fluence::ACL.permitted?(current_user, request.path, Acl::Perm::Write)
		end

    groups_read = Fluence::ACL.groups_having_any_access_to page.url, Acl::Perm::Read, true
    groups_write = Fluence::ACL.groups_having_any_access_to page.url, Acl::Perm::Write, true
    title = "#{page.title} - #{title()}"
    # For menu on the left
    pages = Fluence::PAGES.children1.values
    render "show.slang"
  end

  # post /pages/*path
  def update
    acl_permit! :write
    page = Fluence::PAGES[params.url["path"]]? || (Fluence::Page.new params.url["path"])
    if params.body["rename"]?
      update_rename(page)
    elsif params.body["delete"]?
      update_delete(page)
    # We do not want empty body to mean page deletion.
    #elsif (params.body["body"]?.to_s.empty?)
    #  update_delete(page)
    else
      update_edit(page)
    end
  end

  private def update_rename(page)
    if !params.body["input-page-name"]?.to_s.strip.empty?
      # TODO: verify if the user can write on input-page-name
      # TODO: if input-page-name does not begin with /, do relative rename to the current path
			old_url = page.url
      begin
				old_name = page.name
				Fluence::PAGES.transaction! { |index|
					new_name = params.body["input-page-name"]
					old_path = page.path

					STDERR.puts Fluence::PAGES[page.name]?.nil?, Fluence::PAGES[new_name]?.nil?
					STDERR.puts page.nil?, new_name.nil?
					index.rename page, new_name
					page.rename! current_user, new_name, !!params.body["input-page-overwrite"]?, !!params.body["input-page-subtree"]?
					Fluence::Page.remove_empty_directories old_path
				}
        flash["success"] = "The page #{old_name} has been renamed to #{page.name}."
        redirect_to page.url
      rescue e : Fluence::Page::AlreadyExists
        flash["danger"] = e.to_s
        redirect_to old_url
      end
    else
      redirect_to page.url
    end
  end

  private def update_delete(page)
			pages = [page]
			if !params.body["input-page-subtree-delete"]?.to_s.strip.empty?
				#pages += Fluence::PAGES.find_below page
			end
			pages.each do |p|
				Fluence::PAGES.transaction! { |index| index.delete page }
				page.delete current_user
				flash["success"] += "The page #{page.name} has been deleted. "
				Fluence::Page.remove_empty_directories page.path
			end
      redirect_to "/pages/home"
    rescue err
      # TODO: what if the page is not deleted but not indexed anymore ?
      # Fluence::PAGES.transaction! { |index| index.add page }
      flash["danger"] = "Error: cannot remove #{page.name}, #{err.message}"
      redirect_to page.url
  end

  private def update_edit(page)
      page.write current_user, params.body["body"]
      Fluence::PAGES.transaction! { |index| index.add! page }
      flash["success"] = %Q(The page #{page.name} has been #{page.exists? ? "updated" : "created"}.)
      redirect_to page.url
    rescue err
      flash["danger"] = "Error: cannot update #{page.name}, #{err.message}"
      redirect_to page.url
  end
end
