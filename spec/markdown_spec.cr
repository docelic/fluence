require "tempfile"

describe Wikicr::Markdown do
  it "test internal links" do
    page = Wikicr::Page.new("test")
    index = Wikicr::Page::Index.new("")
    Wikicr::Markdown.to_markdown("[[test]]", page, index).
      should eq("[test](/pages/test)")
    Wikicr::Markdown.to_markdown("[not](http://itisnot/not)", page, index).
      should eq("[not](http://itisnot/not)")
    Wikicr::Markdown.to_markdown("[\\[page]]", page, index).
      should eq("[\\[page]]")
  end

  it "test special internal links cases" do
    page = Wikicr::Page.new("test")
    index = Wikicr::Page::Index.new("")
    Wikicr::Markdown.to_markdown("    [[test]]", page, index).
      should eq("    [[test]]")
    Wikicr::Markdown.to_markdown("```\n[[test]]\n```\n[[test]]", page, index).
      should eq("```\n[[test]]\n```\n[test](/pages/test)")
  end

  it "test internal link with fixed title" do
    page = Wikicr::Page.new("test")
    index = Wikicr::Page::Index.new("")
    Wikicr::Markdown.to_markdown("[[test|title]]", page, index).
      should eq("[title](/pages/test)")
    Wikicr::Markdown.to_markdown("[[test-longer|title a bit longer]]", page, index).
      should eq("[title a bit longer](/pages/test-longer)")
  end
end
