# typed: strict

require "formatter"
require "stringio"
require "rspec/core"
require "perfect_toml"

RSpec.describe Formatter do
  it "should substitute %{job}" do
    template = "this is %{job}"
    template_io = StringIO.open(template)
    output_io = StringIO.open(mode="w+")

    fmt = Formatter.new(template_io, output_io)
    fmt.write_format!(
      {"work" => [], "activity" => [], "project" => []},
      {"title" => "Intel"},
      {work: [], activities: [], projects: []})

    template_io.close
    output_io.close

    expect(output_io.string).to eql("this is Intel")
  end

  it "should substitute %{work}, %{projects}, and %{activities} with selected items and comment out the others" do
    template = "WORK: \n%{work}\n\nPROJECTS: \n%{projects}\n\nACTIVITIES: \n%{activities}"
    template_io = StringIO.open(template)
    output_io = StringIO.open(mode="w+")

    fmt = Formatter.new(template_io, output_io)
    test_entries = PerfectTOML.load_file(File.join(File.dirname(__FILE__), "test_entries.toml"))

    test_entries.transform_values! do |entries|
      entries.values.map {|data| ResumeEntry.new(data)}
    end

    fmt.write_format!(test_entries, {"title" => "AMD"}, {
      work: [true, false, false, true, false],
      projects: [false, true, false],
      activities: [false, false, true]
    })

    template_io.close
    output_io.close

    output = output_io.string
    expect(output).to include("\n\\entry{Full Stack Developer}")
    expect(output).to include("\n\\entry{Data Scientist}")
    expect(output).to include("\n\\entry{Lead Developer}{2021 -- Present}")
    expect(output).to include("\n\\entry{Contributor}{2020 -- Present}{Tech Insights Blog}")
    expect(output).to include("\n% \\entry{Open Source Contributor}")
    expect(output).not_to include("\n\\entry{Open Source Contributor}")
    expect(output).to include("\n% \\entry{Project Lead}{2019 -- 2021}")
    expect(output).not_to include("\n\\entry{Project Lead}{2019 -- 2021}")
  end
end
