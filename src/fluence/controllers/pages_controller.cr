class PagesController < ApplicationController
  # get /sitemap
  def sitemap
    acl_permit! :read
    pages = Fluence::FileTree.build Fluence::Page.subdirectory
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
    if !params.body["new_path"]?.to_s.strip.empty?
      # TODO: verify if the user can write on new_path
      # TODO: if new_path do not begin with /, relative rename to the current path
      begin
        page.rename current_user, params.body["new_path"], !!params.body["new_path_overwrite"]?
        flash["success"] = "The page #{page.url} has been moved to #{params.body["new_path"]}."
        remove_empty_directories page
        redirect_to "/pages/#{params.body["new_path"]}"
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
      remove_empty_directories page
      redirect_to "/pages/home"
    rescue err
      # TODO: what if the page is not deleted but not indexed anymore ?
      # Fluence::PAGES.transaction! { |index| index.add page }
      flash["danger"] = "Error: cannot remove #{page.url}, #{err.message}"
      redirect_to page.real_url
  end

  private def update_edit(page)
      page.write current_user, params.body["body"]
      page.read_title!
      Fluence::PAGES.transaction! { |index| index.add page }
      flash["success"] = "The page #{page.url} has been updated."
      redirect_to page.real_url
    rescue err
      flash["danger"] = "Error: cannot update #{page.url}, #{err.message}"
      redirect_to page.real_url
  end

  private def remove_empty_directories(page : Fluence::Page)
    page_dir_elements = File.dirname(page.path).split File::SEPARATOR
    base_dir_elements = Fluence::Page.subdirectory.split File::SEPARATOR
    while page_dir_elements.size != base_dir_elements.size
      dir_path = page_dir_elements.join(File::SEPARATOR)
      if Dir.empty? dir_path
        Dir.rmdir dir_path
        page_dir_elements.pop
      else
        break
      end
    end
  end
end
