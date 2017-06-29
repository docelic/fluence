get "/sitemap" do |env|
  locals = {title: "sitemap", pages: Wikicr::Page.list}
  render "src/views/sitemap.html.slang", "src/views/layout.html.slang"
end
