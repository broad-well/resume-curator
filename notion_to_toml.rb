# typed: true

require 'csv'
require 'perfect_toml'
require 'sorbet-runtime'

LABEL_MAPPING = {
  "Web backend" => "web_backend",
  "CI/CD" => "ci_cd",
  "Web scalability" => "web_scalability",
  "Containerization" => "containerization",
  "Testing" => "testing",
  "REST" => "rest",
  "Distributed Data" => "distributed_data",
  "Communication" => "communication",
  "DS/AI/ML" => "ds_ai_ml",
  "Cloud" => "cloud",
  "VCS" => "vcs",
  "SQL" => "databases",
  "NoSQL" => "databases",
  "Version control" => "vcs",
  "Source Control" => "vcs",
  "Python" => "python",
  "Troubleshooting" => "troubleshooting",
  "Security" => "security",
  "DevOps" => "devops",
  "UX" => "ux",
  "Leadership" => "leadership",
  "Interdisciplinary" => "interdisciplinary",
  "Agile" => "agile",
  "Web Frontend" => "web_frontend",
  "Web frontend" => "web_frontend",
  "Databases" => "databases",
  "Creativity" => "creativity",
  "Data manipulation" => "data_manipulation",
  "Data visualization" => "data_viz",
  "Java/C#" => "java_csharp",
  "Open Source" => "open_source",
  "Test-Driven Development" => "tdd",
  "Research" => "research",
  "Learning" => "learning",
  "Algo&DS" => "ds_algo",
  "Mobile" => "mobile",
  "Simulation" => "simulation",
  "SDLC" => "sdlc"
}

extend T::Sig

sig {params(labels: T.nilable(String), lookup: T::Boolean).returns(T::Array[String])}
def labels_to_quals(labels, lookup=true)
  return [] if labels.nil?
  return labels.split(", ") unless lookup
  LABEL_MAPPING.fetch_values(*labels.split(", ")) do |x|
    raise KeyError.new(x)
  end
end

sig {params(job_name: String).returns(String)}
def generate_toml_filename(job_name)
  File.join("postings", job_name.downcase.gsub(/\s+/, '-') + ".toml")
end

table = T.let(CSV.table("notion_queue.csv"), CSV::Table)
table.by_row.each do |row|
  next if row[:applied] == 'Yes'
  p row
  toml_out = {
    "title" => row[:name],
    "required" => labels_to_quals(row[:minimum_qualifications]),
    "preferred" => labels_to_quals(row[:preferred_qualifications]),
    "keywords" => labels_to_quals(row[:keywords], lookup=false),
    "tagline" => row[:tagline] || ""
  }
  File.write(generate_toml_filename(row[:name]), PerfectTOML.generate(toml_out), encoding: 'utf-8')
end
