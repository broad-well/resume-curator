#!/usr/bin/env ruby
# typed: true

require "sorbet-runtime"
require "perfect_toml"
require_relative "entries"
require_relative "formatter"
require_relative "optimizer"

entries = PerfectTOML.load_file("entries.toml")
job = PerfectTOML.load_file(STDIN)

entries.transform_values! do |items|
  items.values.map {|data| ResumeEntry.new(data)}
end

work = entries["work"]
projects = entries["project"]
activities = entries["activity"]

curation = Curation.new(work, projects, activities, job)
curation.solve!
decisions = curation.all_decisions
File.open("template.tex") do |template|
  fmt = Formatter.new(template, STDOUT)
  fmt.write_format!(entries, job, decisions)
end
