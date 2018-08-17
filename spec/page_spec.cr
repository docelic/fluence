describe Fluence::Page do
  it "test basic" do
    page = Fluence::Page.new("home")
    page.name.should eq "home"
    page.url.should eq "/pages/home"
    page.path.should eq File.expand_path("data/pages/home.md")
  end
end
