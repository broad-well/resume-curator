# typed: true
require "perfect_toml"

toml = PerfectTOML.load_file "entries.toml"
top_keys = %w[work project activity].freeze
entries = top_keys.flat_map {|key| toml[key].values }

keywords = entries.flat_map {|k| k["keywords"]}
freq = Hash.new(0)
keywords.each do |kw|
  freq[kw] += 1
end

puts freq.sort_by{|kv| kv[1]}