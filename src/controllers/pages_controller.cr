def add_page(page, stack = [] of String)
  String.build do |str|
    Slang.embed("src/views/pages/sitemap.directory.slang", "str")
  end
end

class PagesController < ApplicationController
  # get /sitemap
  def sitemap
    acl_permit! :read
    pages = Wikicr::FileTree.build Wikicr::OPTIONS.basedir
    render "sitemap.slang"
  end

  # get /pages
  def index
    redirect_to "/pages/home"
  end

  # get /pages/search?q=
  def search
    # user_must_be_logged!
    query = params["q"]
    page = Wikicr::Page.new(query)
    # TODO: a real search
    redirect_to query.empty? ? "/pages" : page.real_url
  end

  macro fetch_params
  end

  # get /pages/*path
  def show
    acl_permit! :read
    page = Wikicr::Page.new url: params["path"], read_title: true
    if (params["edit"]?) || !page.exists?(current_user)
      body = page.read(current_user) rescue ""
      flash["info"] = "The page #{page.url} does not exist yet."
      acl_permit! :write
      render "edit.slang"
    else
      body_html = Markdown.to_html page.read(current_user)
      Wikicr::ACL.load!
      groups_read = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Read, true
      groups_write = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Write, true
      render "show.slang"
    end
  end

  # post /pages/*path
  def update
    acl_permit! :write
    page = Wikicr::Page.new url: params["path"], read_title: true
    if (params["body"]?.to_s.empty?)
      page.delete current_user rescue nil
      flash["info"] = "The page #{page.url} has been deleted."
      Wikicr::PAGES.transaction! { |index| index.delete page }
      redirect_to "/pages/"
    else
      page.write params["body"], current_user
      flash["info"] = "The page #{page.url} has been updated."
      Wikicr::PAGES.transaction! { |index| index.add page }
      redirect_to page.real_url
    end
  end
end
