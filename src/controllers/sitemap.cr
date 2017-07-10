def add_page(page, stack = [] of String)
  String.build do |str|
    Slang.embed("src/views/sitemap.directory.html.slang", "str")
  end
end

get "/sitemap" do |env|
  acl_permit! :read
  locals = {title: "sitemap", pages: Wikicr::FileTree.build(Wikicr::OPTIONS.basedir)}
  render "src/views/sitemap.html.slang", "src/views/layout.html.slang"
end
