require "tempfile"

describe Fluence::Markdown do
  it "test internal links" do
    page = Fluence::Page.new("test")
    index = Fluence::Index(Fluence::Page).new("")

		# Disabled because these parts are currently unused
    #Fluence::Markdown.to_markdown("[[test]]", page, index).  should eq("[test](/pages/test)")
    Fluence::Markdown.to_markdown("[not](http://itisnot/not)", page, index).  should eq("[not](http://itisnot/not)")
    Fluence::Markdown.to_markdown("[\\[page]]", page, index).  should eq("[\\[page]]")
  end

  it "test special internal links cases" do
    #page = Fluence::Page.new("test")
    #index = Fluence::Index(Fluence::Page).new("")

		# Disabled because these parts are currently unused
    #Fluence::Markdown.to_markdown("    [[test]]", page, index).  should eq("    [[test]]")
    #Fluence::Markdown.to_markdown("```\n[[test]]\n```\n[[test]]", page, index).  should eq("```\n[[test]]\n```\n[test](/pages/test)")
  end

  it "test internal link with fixed title" do
    #page = Fluence::Page.new("test")
    #index = Fluence::Index(Fluence::Page).new("")

		# Disabled because these parts are currently unused
    #Fluence::Markdown.to_markdown("[[test|title]]", page, index).  should eq("[title](/pages/test)")
    #Fluence::Markdown.to_markdown("[[test-longer|title a bit longer]]", page, index).  should eq("[title a bit longer](/pages/test-longer)")
    #Fluence::Markdown.to_markdown("[[test-empty|]]", page, index).  should eq("[test-empty](/pages/test-empty)")
  end
end
