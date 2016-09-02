# How_is Roadmap

2016-09-01

A brief overview of how_is' goals and current status.

## Current Progress

So far, HTML and JSON reports work extremely well. PDF support has lagged
due to difficulties finding a library that can do everything needed.
There is an integration test that fails for an unknown reason.

Reports can be generated using a config file, typically named
how_is.yml. This has been successfully used for
[how-is.github.io/how-is-rubygems](https://how-is.github.io/how-is-rubygems/)
([how_is.yml source](https://github.com/how-is/how-is-rubygems/blob/gh-pages/how_is.yml)).

how_is can be used as either an executable or a library, however
[library usage is currently undocumented](https://github.com/how-is/how_is/issues/45).

Metrics that have been implemented include:

* number of open Issues,
* number of open Pull Requests,
* number of issues associated with each label, as well as the number associated with no label,
* average Issue age,
* average Pull Request age,
* date oldest Issue was opened,
* date oldest Pull Request was opened.

HTML reports contain a graph showing the issues assigned each label (or no
label). PDF reports contain a less-nice variant of
that graph.

## Goals

The next major steps are complex metrics and creating a web
dashboard for multiple projects.

Complex metrics require things like cloning the repository or making multiple API requests.

### Complex Metrics

Complex metrics will include:

* code churn (code change over time),
* average response time by a team member in the past week,
* graph of average response time by a team member per week.

These metrics serve to either quantify the state of the repository, quantify the state of the codebase itself, or both. By quantifying the state of the issue tracker and codebase, it will hopefully be easier to decide what needs to be done.

### Dashboard

The end goal for the dashboard is to have a website where you can view
information about multiple projects, and identify trends.

Currently, there is a way to generate reports based on a configuration
file, which has been successfully used to generate [reports for RubyGems](https://how-is.github.io/how-is-rubygems/).
However, these have to be manually generated each month.

Idealy, these could be generated automatically, and would be stored in a
database. Once that is done, the information can be more easily retrieved
in groups and used to generate graphs or more complex summaries.

## Milestones

Before beginning work on the dashboard, the how_is APIs need to be
documented and possibly cleaned up.

Once that's done, the plan for beginning work on the dashboard is
roughly:

1. decide what the dashboard will eventually contain,
2. create a design for the finished dashboard (so we know what's being
  worked towards),
3. figure out the software architecture required to support this,
4. determine what parts of the dashboard are currently implementable,
5. create an intermediate design for what how_is can actually support
  (this should be a subset of the original design).

Once these have been done, it should be possible to have people work on
the dashboard in parallel.
