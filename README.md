<h1 style="text-align:center">Résumé curator</h1>

Automatically curate the most appropriate résumé items for each job posting to create a custom résumé that fits on 1 page. In summary,

```
(job posting, complete resume) -> tailored resume (1 page)
```

## Job posting

Each job posting is summarized as:
- _Title_: Very short label for the job and/or the company
- _Required qualifications_: Set of keywords
- _Preferred qualifications_: Set of keywords
- Important, specific keywords denoting skills

Job postings are fed into the program in TOML format through `stdin`. The format shall contain keys `required`, `preferred`, `title`, and `keywords`.

## Resume template

The resume is typeset in LaTeX. The template TeX file (template.tex) provides space for:

- `%{job}` Short title for the job or company
- `%{tagline}` A tagline (like "Enthusiastic software engineering generalist")
- `%{work}` Work experience
- `%{projects}` Projects
- `%{activities}` Activities
- `%{languages}` Languages
- `%{libraries}` Libraries
- `%{platforms}` Platforms

The curator is responsible for substituting these placeholders with concrete information.

## Resume information

Information to be substituted into the template placeholders is sourced from entries.toml, which must contain `[work]`, `[project]`, `[activities]`, and `[technologies]` entries. Each entry in `[work]`, `[project]`, `[activities]` must contain:
- `name`: Short label for the entry for debugging and logging
- `tex`: The TeX snippet for the entry
- `appeal`: The appeal of this entry with respect to all relevant keywords. Appeal is rated on a scale from 1 to 10.
- `lines`: The number of lines occupied by this entry. The curator uses this to ensure that the output does not exceed 1 page.
- `order`: A string used by the curator to sort entries chronologically in the output.

### Example

```toml
[project.curator]
name = "Resume Curator"
tex = '''
\ownentry{R\'esum\'e Curator}{2023}{}
\begin{myitemize}
  \item Ideated original program that curates optimal r\'esum\'es for specific job postings
  \item Independently implemented program in Ruby
\end{myitemize}
'''
appeal.creativity = 6
appeal.ruby = 8
appeal.impact = 3
lines = 3
order = "2023.L.2"
```

Each entry in `[technologies]` must contain keys `type` (`language`, `library`, or `framework`), `tex`, and `appeal` with the same format as above.

## Procedural overview

- **Read inputs**: Job posting, source information
- **Compose optimization problem**: Seek to maximize sum of appeal while limiting the output to 1 page
- **Organize substitutions**: Solve the optimization problem and convert the solution to a set of substitutions into the template (in this case, a hash for `%`)
- **Apply substitutions and write output**

### Optimization problem details

The **objective** is to maximize the sum of the total appeal score over all required qualifications * 2 + the sum of the total appeal score over all preferred qualifications. The **constraints** are:
- The output cannot exceed 1 page. The sum of the expected vertical space taken up by all the entries cannot exceed 1 page minus the existing elements of the page.
- There must be recent entries. At least one work experience item should be from the current year or the year before, while at least 2 project items should be from the current year or the year before.