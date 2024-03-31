# typed: strict

require "entries"
require "optimizer"
require "rspec/core"
require "perfect_toml"

RSpec.describe Curation do
  it "should acccept a correctly formed job posting" do
    posting = {
      "title" => "Intel Full Stack",
      "required" => ["web_frontend", "web_backend", "databases", "vcs"],
      "preferred" => ["ci_cd", "web_scalability", "containerization", "testing", "rest"],
      "keywords" => []
    }
    curation = Curation.new([], [], [], posting)
  end

  it "should reject a job posting that lacks a key" do
    posting = {
      "title" => "Cadence",
      "required" => ["security", "interdisciplinary"],
      "preferred" => ["ds_algo", "data_manipulation"],
      "keywords" => ["VLSI"]
    }
    posting.keys.each do |k|
      v = posting.delete k
      expect { Curation.new([], [], [], posting) }.to raise_error(TypeError)
    end
  end

  it "should form a valid solution with enough entries provided" do
    extend T::Sig

    toml = PerfectTOML.load_file(File.join(File.dirname(__FILE__), "test_entries.toml"))
    sig { params(category: T.untyped).returns(T::Array[ResumeEntry]) }
    def category_to_entries(category)
      category.values.map {|item| ResumeEntry.new(item)}
    end
    curation = Curation.new(
      category_to_entries(toml["work"]),
      category_to_entries(toml["project"]),
      category_to_entries(toml["activity"]),
      {
        "title" => "Intel Full Stack",
        "required" => ["web_frontend", "web_backend", "databases", "vcs"],
        "preferred" => ["ci_cd", "web_scalability", "containerization", "testing", "rest"],
        "keywords" => []
      }
    )
    curation.solve!
    expect(curation.decisions(:work).count(true)).to(be > 3)
    expect(curation.decisions(:projects).count(true)).to(be > 1)
    expect(curation.decisions(:activities).count(true)).to(be > 0)
  end
end
