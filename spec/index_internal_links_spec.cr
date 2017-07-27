describe Wikicr::Page::InternalLinks do
  it "test basic internal links listing" do
    index = Wikicr::Page::Index.new("")
    page = Wikicr::Page.new(url: "home")
    str = "I [[am-a-link]] and [[me-too]]\n"
    links = Wikicr::Page::InternalLinks.links_in_content(str, index, page)

    link1 = "am-a-link"
    link2 = "me-too"
    link1_idx = str.index link1
    link2_idx = str.index link2

    links.size.should eq 2
    links[0][0].should eq link1_idx
    links[0][1].should eq "/pages/#{link1}"
    links[1][0].should eq link2_idx
    links[1][1].should eq "/pages/#{link2}"
  end
end
