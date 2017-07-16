

class PagesController < ApplicationController
  # get /sitemap
  def sitemap
    acl_permit! :read
    pages = Wikicr::FileTree.build Wikicr::OPTIONS.basedir
    render "sitemap.slang"
  end

  # get /pages/search?q=
  def search
    query = params.query["q"]
    page = Wikicr::Page.new(query)
    # TODO: a real search
    redirect_to query.empty? ? "/pages/home" : page.real_url
  end

  # get /pages/*path
  def show
    acl_permit! :read
    flash["danger"] = params.query["flash.danger"] if params.query["flash.danger"]?
    page = Wikicr::Page.new url: params.url["path"], read_title: true
    if (params.query["edit"]?) || !page.exists?
      body = page.read rescue ""
      flash["info"] = "The page #{page.url} does not exist yet." if !page.exists?
      acl_permit! :write
      render "edit.slang"
    else
      body_html = Wikicr::Page::Markdown.to_html page.read, page, Wikicr::PAGES.load!
      Wikicr::ACL.load!
      groups_read = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Read, true
      groups_write = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Write, true
      render "show.slang"
    end
  end

  # post /pages/*path
  def update
    acl_permit! :write
    pp params.body
    page = Wikicr::Page.new url: params.url["path"], read_title: true
    if params.body["rename"]?
      if !params.body["new_path"]?.to_s.strip.empty?
        # TODO: verify if the user can write on new_path
        # TODO: if new_path do not begin with /, relative rename to the current path
        page.rename current_user, params.body["new_path"]
        flash["success"] = "The page #{page.url} has been moved to #{params.body["new_path"]}."
        redirect_to "/pages/#{params.body["new_path"]}"
      else
        redirect_to page.real_url
      end
    elsif (params.body["body"]?.to_s.empty?)
      page.delete current_user rescue nil
      flash["success"] = "The page #{page.url} has been deleted."
      Wikicr::PAGES.transaction! { |index| index.delete page }
      redirect_to "/pages/home"
    else
      page.write current_user, params.body["body"]
      page.read_title!
      flash["success"] = "The page #{page.url} has been updated."
      Wikicr::PAGES.transaction! { |index| index.add page }
      redirect_to page.real_url
    end
  end
end
