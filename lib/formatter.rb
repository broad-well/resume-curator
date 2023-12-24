# typed: strict

require "sorbet-runtime"
require "stringio"
require_relative "entries"

class Formatter
  extend T::Sig

  sig {params(template_stream: T.any(StringIO, File, IO), output_stream: T.any(StringIO, File, IO)).void}
  def initialize(template_stream, output_stream)
    @template = template_stream
    @output = output_stream
  end

  sig do params(
    entries: T::Hash[String, T::Array[ResumeEntry]],
    job: T::Hash[String, T::untyped],
    decisions: T::Hash[Symbol, T::Array[T::Boolean]]).void
  end
  def write_format!(entries, job, decisions)
    params = {
      job: job["title"],
      work: format_section(T.must(entries["work"]), T.must(decisions[:work])),
      projects: format_section(T.must(entries["project"]), T.must(decisions[:projects])),
      activities: format_section(T.must(entries["activity"]), T.must(decisions[:activities])),
    }
    while (line = @template.gets)
      @output.write(line % params)
    end
  end

  private

  sig {params(entries: T::Array[ResumeEntry], decisions: T::Array[T::Boolean]).returns(String)}
  def format_section(entries, decisions)
    entries.map(&:tex).zip(decisions).map do |(tex, include)|
      include ? tex : comment_out(tex)
    end.join("\n\n")
  end

  sig { params(tex: T.untyped).returns(String) }
  def comment_out(tex)
    "% " + tex.gsub(/\n/, "\n% ")
  end
end
