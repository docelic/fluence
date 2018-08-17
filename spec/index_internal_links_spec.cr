describe Fluence::Page::InternalLinks do
  it "test basic internal links listing" do
    index = Fluence::Page::Index.new("")
    page = Fluence::Page.new("home")
    str = "I [[am-a-link]] and [[me-too]]\n"
    links = Fluence::Page::InternalLinks.links_in_content str

    link1 = "am-a-link"
    link2 = "me-too"
    link1_idx = str.index link1
    link2_idx = str.index link2

    links.size.should eq 2
    links[0][0].should eq link1_idx
    links[0][1].should eq link1
    links[1][0].should eq link2_idx
    links[1][1].should eq link2
  end
end
