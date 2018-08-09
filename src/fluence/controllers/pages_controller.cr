class PagesController < ApplicationController
  # get /sitemap
  def sitemap
    acl_permit! :read
    pages = Fluence::FileTree.build Fluence::Page.subdirectory
		media = Fluence::FileTree.build Fluence::Media.subdirectory
    title = "Sitemap - #{title()}"
    render "sitemap.slang"
  end

  # get /pages/search?q=
  def search
    query = params.query["q"]
    page = Fluence::Page.new(query)
    # TODO: a real search
    title = "Search Results - #{title()}"
    redirect_to query.empty? ? "/pages/home" : page.real_url
  end

  # get /pages/*path
  def show
    acl_permit! :read
    flash["danger"] = params.query["flash.danger"] if params.query["flash.danger"]?
    pp params.url
    page = Fluence::Page.new url: params.url["path"], read_title: true
#    if (params.query["edit"]?) || !page.exists?
#      show_edit(page)
#    else
      show_show(page)
#    end
  end

  private def show_show(page)
    body = page.read rescue ""
    body_html = body ? Fluence::Markdown.to_html body, page, Fluence::PAGES.load! : ""
    Fluence::ACL.load!

		if !page.exists?
			flash["info"] = "The page #{page.url} does not exist yet."
			flash["info"] += " You could create it by typing in and saving new content." if
				Fluence::ACL.permitted?(current_user, request.path, Acl::Perm::Write)
		end

    groups_read = Fluence::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Read, true
    groups_write = Fluence::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Write, true
    title = "#{page.title} - #{title()}"
    # For menu on the left
    pages = Fluence::FileTree.build Fluence::Page.subdirectory
    render "show.slang"
  end

  # post /pages/*path
  def update
    acl_permit! :write
    page = Fluence::Page.new url: params.url["path"], read_title: true
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
      # TODO: if input-page-name do not begin with /, relative rename to the current path
      begin
        new_page = page.rename current_user, params.body["input-page-name"], !!params.body["input-page-overwrite"]?
        flash["success"] = "The page #{page.url} has been renamed to #{new_page.url}."
				Fluence::PAGES.transaction! { |index| index.rename page, new_page }
        Fluence::Page.remove_empty_directories page.path
        redirect_to new_page.real_url
      rescue e : Fluence::Page::AlreadyExist
        flash["danger"] = e.to_s
        redirect_to page.real_url
      end
    else
      redirect_to page.real_url
    end
  end

  private def update_delete(page)
      Fluence::PAGES.transaction! { |index| index.delete page }
      page.delete current_user
      flash["success"] = "The page #{page.url} has been deleted."
      Fluence::Page.remove_empty_directories page.path
      redirect_to "/pages/home"
    rescue err
      # TODO: what if the page is not deleted but not indexed anymore ?
      # Fluence::PAGES.transaction! { |index| index.add page }
      flash["danger"] = "Error: cannot remove #{page.url}, #{err.message}"
      redirect_to page.real_url
  end

  private def update_edit(page)
			is_new = page.is_new?
      page.write current_user, params.body["body"]
      page.read_title!
      Fluence::PAGES.transaction! { |index| index.add! page }
      flash["success"] = %Q(The page #{page.url} has been #{is_new ? "created" : "updated"}.)
      redirect_to page.real_url
    rescue err
      flash["danger"] = "Error: cannot update #{page.url}, #{err.message}"
      redirect_to page.real_url
  end
end
