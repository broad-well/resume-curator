# typed: strict

require "sorbet-runtime"
require "opt-rb"
require "highs"

REQ_MULTIPLIER = 2

class Curation
  extend T::Sig
  public

  sig {params(
    work: T::Array[ResumeEntry],
    projects: T::Array[ResumeEntry],
    activities: T::Array[ResumeEntry],
    job: T::Hash[String, T.any(String, T::Array[String])]
  ).void}
  def initialize(work, projects, activities, job)
    @work = work
    @projects = projects
    @activities = activities
    @job_title = T.let(T.cast(job["title"], String), String)
    @job_required = T.let(T.cast(job["required"] || [], T::Array[String]), T::Array[String])
    @job_preferred = T.let(T.cast(job["preferred"] || [], T::Array[String]), T::Array[String])
    @job_keywords = T.let(T.cast(job["keywords"] || [], T::Array[String]), T::Array[String])

    @work_include = T.let(entries_to_include_variables(work), T::Array[Opt::Binary])
    @projects_include = T.let(entries_to_include_variables(projects), T::Array[Opt::Binary])
    @activities_include = T.let(entries_to_include_variables(activities), T::Array[Opt::Binary])
    @prob = T.let(Opt::Problem.new, Opt::Problem)
  end

  sig {void}
  def solve!
    constrain_one_page
    constrain_min_per_category
    maximize_appeal
    @prob.solve
  end

  sig {params(category: Symbol).returns(T::Array[T::Boolean])}
  def decisions(category)
    T.must(all_decisions[category])
  end

  sig { returns(T::Hash[Symbol, T::Array[T::Boolean]]) }
  def all_decisions
    {
      work: @work_include.map(&:value),
      projects: @projects_include.map(&:value),
      activities: @activities_include.map(&:value)
    }
  end

  private

  sig {params(entries: T::Array[ResumeEntry]).returns(T::Array[Opt::Binary])}
  def entries_to_include_variables(entries)
    entries.map {|ent| Opt::Binary.new(ent.name)}
  end

  sig {void}
  def constrain_one_page
    # constrain to 45 lines
    vars = @work_include + @projects_include + @activities_include
    entries = @work + @projects + @activities
    line_sum = (vars.zip(entries).map do |(var, entry)|
      var * T.must(entry).lines
    end).sum
    @prob.add(line_sum <= 45)
  end

  sig {void}
  def constrain_min_per_category
    # at least 30% of each category should be represented
    # at least 1 of each category should be recent (70th ordering percentile or greater)
    [
      [@work, @work_include],
      [@projects, @projects_include],
      [@activities, @activities_include]
    ].each do |(entries, vars)|
      @prob.add(vars.sum >= vars.length * 0.3)
      ordered_items = entries.zip(vars).sort_by {|(e, v)| e.order}
      @prob.add(
        T.must(T.must(
          ordered_items.slice((ordered_items.length * 0.7).floor..))
            .map {|(_, v)| v}.sum) >= 1)
    end
  end

  sig {void}
  def maximize_appeal
    # maximize "total appeal"
    # for each category, for each required qualification, sum up the appeal
    # also add up the keywords satisfied

    required_appeal_sum = sum_appeals(@job_required)
    preferred_appeal_sum = sum_appeals(@job_preferred)
    keywords_sum = sum_keywords * 10
    @prob.maximize(required_appeal_sum * REQ_MULTIPLIER + preferred_appeal_sum + keywords_sum)
  end

  sig {params(quals: T::Array[String]).returns(T.untyped)}
  def sum_appeals(quals)
    quals.map do |qual|
      [
        [@work, @work_include],
        [@projects, @projects_include],
        [@activities, @activities_include]
      ].map do |(entries, vars)|
        entries.zip(vars).map do |(entry, var)|
          T.must(var) * (entry.appeal[qual] || 0)
        end.sum
      end.sum
    end.sum
  end

  sig {returns(T.untyped)}
  def sum_keywords
    [
      [@work, @work_include],
      [@projects, @projects_include],
      [@activities, @activities_include]
    ].map do |(entries, vars)|
      entries.zip(vars).map do |(entry, var)|
        T.must(var) * @job_keywords.intersection(entry.keywords).length
      end.sum
    end.sum
  end
end
