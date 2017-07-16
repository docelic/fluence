require "tempfile"

describe Wikicr::Page::Markdown do
  it "test internal links" do
    page = Wikicr::Page.new("test")
    index = Wikicr::Page::Index.new("")
    Wikicr::Page::Markdown.to_markdown("[[test]]", page, index).
      should eq("[test](/pages/test)")
    Wikicr::Page::Markdown.to_markdown("[not](http://itisnot/not)", page, index).
      should eq("[not](http://itisnot/not)")
    Wikicr::Page::Markdown.to_markdown("[\\[page]]", page, index).
      should eq("[\\[page]]")
  end

  it "test special internal links cases" do
    page = Wikicr::Page.new("test")
    index = Wikicr::Page::Index.new("")
    Wikicr::Page::Markdown.to_markdown("    [[test]]", page, index).
      should eq("    [[test]]")
    Wikicr::Page::Markdown.to_markdown("```\n[[test]]\n```\n[[test]]", page, index).
      should eq("```\n[[test]]\n```\n[test](/pages/test)")
  end
end
