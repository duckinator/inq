# How_is Roadmap

A brief overview of where how_is stands and the plans for it.

## Goals

How_is is intended to be usable both as a standalone program and a as library, with reports generated as either files or Ruby Strings. Initial export formats supported will be JSON, PDF, and HTML. When exporting a report, you can use the data from a previous JSON export to avoid making network requests.

Metrics will be divided into two categories during implementation: Simple and Complex. Simple ones will be doable using only the information gathered from one API call to the issue tracker. Complex metrics require things like cloning the repository or making multiple API requests.

Simple metrics will include:

* number of open Issues,
* number of open Pull Requests,
* number of issues associated with each label, as well as the number associated with no label,
* average Issue age,
* average Pull Request age,
* date oldest Issue was opened,
* date oldest Pull Request was opened.

Complex metrics will include:

* code churn (code change over time),
* average response time by a team member in the past week,
* graph of average response time by a team member per week.

These metrics serve to either quantify the state of the repository, quantify the state of the codebase itself, or both. By quantifying the state of the issue tracker and codebase, it will hopefully be easier to decide what needs to be done.

Once HTML export is implemented, a web service is planned to be created which tracks these metrics over time for the RubyGems repository. The details of this have not been fully fleshed out, but I am attempting to design the library in such a way to allow the flexibility required to do this.

## Current Status

As of June 15th 2016, how_is supports exports to JSON or PDF, but not HTML. For JSON and PDF, all Simple metrics have been implemented in some form, although they made need some polish ([#8](https://github.com/duckinator/how_is/issues/8)). HTML export is not implemented, and no Complex metrics are implemented. Tracking the number of issues without labels has also not been implemented ([#1](https://github.com/duckinator/how_is/issues/1)).

Exporting to Ruby Strings that contain valid JSON, PDF, or HTML documents has also not been implemented ([#7](https://github.com/duckinator/how_is/issues/7)).

Authentication is not being used, but will likely be necessary, as it would raise the API rate limits ([#6](https://github.com/duckinator/how_is/issues/6)).

### Requirements for 1.0

Once JSON and PDF exports are fully implemented ([#1](https://github.com/duckinator/how_is/issues/1)) and the README has a proper list of the metrics covered, v1.0 will be released.

### Requirements for 2.0

Once everything required for v1.0 as well as exporting to Strings ([#7](https://github.com/duckinator/how_is/issues/7)) has been implemented, v2.0 will be released.

### Other changes

All other changes ([#8](https://github.com/duckinator/how_is/issues/8), [#6](https://github.com/duckinator/how_is/issues/6), any changes without an accompanying issue) will be grouped together in either the next major release, or a separate minor release.
