def add_page(page, stack = [] of String)
  String.build do |str|
    Slang.embed("src/views/pages/sitemap.directory.slang", "str")
  end
end

def create_toc_line(line)
  "<li>#{line}</li>"
end

def add_toc_level(b, index_entry, current_id = 0, last_head = 0)
  return if index_entry.size == current_id
  current_entry = index_entry[current_id]
  current_head = current_entry[0]
  current_head_value = current_entry[1]
  if current_head > last_head
    b << "<ul>" << create_toc_line(current_head_value)
  elsif current_head < last_head
    b << "</ul>" << create_toc_line(current_head_value)
  else
    b << create_toc_line(current_head_value)
  end
  return add_toc_level(b, index_entry, current_id + 1, current_head)
end

def add_toc(index_entry)
  # (index_entry.values.map(&.size).sum + index_entry.size * 9)
  toc = String.build do |b|
    add_toc_level(b, index_entry)
  end
  String.build do |str|
    Slang.embed("src/views/pages/toc.slang", "str")
  end
end

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
