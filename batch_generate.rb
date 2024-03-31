# frozen_string_literal: true
# typed: true

require 'pathname'
require 'sorbet-runtime'

postings = Dir['postings/*.toml'].select {|x| File.file?(x)}

postings.each do |path|
  id = T.must(Pathname(path).basename.to_s.split('.')[0])
  out = File.join("out", id + ".tex")
  File.open(path) do |input|
    File.open(out, "w+") do |output|
      system("lib/curator.rb", in: input, out: output)
    end
  end
  puts "completed #{id}"
end