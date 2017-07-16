# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com) and
this project adheres to [Semantic Versioning](http://semver.org).

## [Unreleased]

### Changes

* Include name of rules in RuboCop output. ([#175](https://github.com/how-is/how_is/pull/175))
* RuboCop 0.49.1. ([#174](https://github.com/how-is/how_is/pull/174))
* RuboCop warning removal. ([#173](https://github.com/how-is/how_is/pull/173))

## [v18.0.4]

This release ([snapshot](https://github.com/how-is/how_is/tree/v18.0.4))
is exclusively cleaning up RuboCop violations and updating dependencies.
There should be no noticeable changes in functionality.

### Changes

* Use Hashie stable; update Gemfile/add Gemfile.lock. ([#170](https://github.com/how-is/how_is/pull/170))
* Pass -w to Ruby when running 'rake spec'. ([#169](https://github.com/how-is/how_is/pull/169))
* Rubocop cleanup. ([#167](https://github.com/how-is/how_is/pull/167))
* Gemfile: use Hashie from master branch. ([#166](https://github.com/how-is/how_is/pull/166))
* Update github_api, contracts to latest. ([#165](https://github.com/how-is/how_is/pull/165))
* Fix (a significant number of) RuboCop violations. ([#162](https://github.com/how-is/how_is/pull/162))
* README: Drop from_config_file reference. ([#161](https://github.com/how-is/how_is/pull/161))
* Move rubocop dependency to gemspec. ([#160](https://github.com/how-is/how_is/pull/160))

## [v18.0.3]

This release ([snapshot](https://github.com/how-is/how_is/tree/v18.0.3))
fixes the things the last few releases broke. I think. Hopefully.

It also includes some refactoring work, and the addition of a RuboCop
configuration.

@duckinator enabled [Hound CI](https://houndci.com) for the repository, which
should find any RuboCop violations that are added in PRs. The preexisting
RuboCop violations (of which there are many) need to be addressed separately,
and there will likely be an entire release dedicated to that.

### Changes

* Add RuboCop config ([#158](https://github.com/how-is/how_is/pull/158))
* CLI parser refactor ([#157](https://github.com/how-is/how_is/pull/157))
* exe/how_is: Reinstate to_json, to_html ([#150](https://github.com/how-is/how_is/pull/150), by @olleolleolle)

## [v18.0.2]

This release ([snapshot](https://github.com/how-is/how_is/tree/v18.0.2))
_actually_ fixes the `--config` flag, which made an unecessary method
call.

### Changes

* v18.0.2 - Remove unnecessary `.send()` call in exe/how_is.
  ([#148](https://github.com/how-is/how_is/pull/148))

## [v18.0.1]

This release ([snapshot](https://github.com/how-is/how_is/tree/v18.0.1))
fixes the `--config` flag, which was previously using the wrong method.

### Changes

* v18.0.1 - fix `--config` flag.
  ([#147](https://github.com/how-is/how_is/pull/147))

## [v18.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v18.0.0))
vastly improves documentation, fixes the `--from` flag, and adds the
`HowIs.from_hash` method (used by the
[dashboard](https://github.com/how-is/dashboard)).

Pull Requests for this release can be [viewed on
GitHub](https://github.com/how-is/how_is/pulls?utf8=&q=is%3Apr%20created%3A2017-02-10..2017-03-03).

### Additions

* Add/improve inline code documentation.
  ([#132](https://github.com/how-is/how_is/pull/132))
* Move documentation from design/ to README.
  ([#143](https://github.com/how-is/how_is/pull/143))
* Add `HowIs.from_hash` method.
  ([#144](https://github.com/how-is/how_is/pull/144))

### Changes

* Unpin Rack version. ([#139](https://github.com/how-is/how_is/pull/139))
* Fix --from. ([#141](https://github.com/how-is/how_is/pull/141))

### Miscellaneous

Things that don't affect users of how\_is.

* Fix grammar in gemspec.
  ([#129](https://github.com/how-is/how_is/pull/129))
* Fix URL in gemspec. ([#130](https://github.com/how-is/how_is/pull/130))
* Remove shebang line from lib/ file.
  ([#131](https://github.com/how-is/how_is/pull/131))


## [v17.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v17.0.0))
makes `HowIs.from_json` parse _all_ dates, not just _some_ dates.
(Whoops.)

### Changes

* Make `HowIs.from_json` parse _all_ dates, not just some of them.
  ([#128](https://github.com/how-is/how_is/pull/128))

## [v16.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v16.0.0))
makes `HowIs.from_json` actually parse dates.

### Changes

* Make `HowIs.from_json` parse dates.
  ([#127](https://github.com/how-is/how_is/pull/127))

## [v15.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v15.0.0))
implements `HowIs.from_json`.

### Changes

* Implemented `How_is.from_json`.
  ([#126](https://github.com/how-is/how_is/pull/126))

## [v14.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v14.0.0))
made JSON reports include Pulse data, thus making `HowIs.from_json()`
not make any network requests at all.

### Changes

* Remove dead code. ([#123](https://github.com/how-is/how_is/pull/123))
* Include Pulse data in JSON reports.
  ([#125](https://github.com/how-is/how_is/pull/125))

## [v13.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v13.0.0))
largely focused on an API redesign.

Pull requests for this release can be [viewed on
GitHub](https://github.com/how-is/how_is/pulls?utf8=&q=is%3Apr%20created%3A2016-12-12..2017-02-09).

### Changed

* API overhaul. ([#115](https://github.com/how-is/how_is/issues/115), [#117](https://github.com/how-is/how_is/pull/117))
* Raise an exception/show a CLI warning if the provided repository name
  isn't in the "user/repo" format.
  ([#98](https://github.com/how-is/how_is/pull/98))

## [v12.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v12.0.0))
largely focused on refactoring and developer experience improvements
(e.g. adding Rake tasks and improving the generated JSON and HTML).

Pull Requests for this release can be [viewed on
GitHub](https://github.com/how-is/how_is/pulls?utf8=&q=is%3Apr%20created%3A2016-11-11..2016-12-11).

### Added

- Include newest PR/issue in reports.
  ([#85](https://github.com/how-is/how_is/pull/85))

### Changed

- Refactoring. ([#79](https://github.com/how-is/how_is/pull/79), [#80](https://github.com/how-is/how_is/pull/80), [#82](https://github.com/how-is/how_is/pull/82), [#88](https://github.com/how-is/how_is/pull/88))
- JSON and HTML reports have nicer source.
  ([#82](https://github.com/how-is/how_is/pulls/82),
  [#84](https://github.com/how-is/how_is/pulls/84))
- Handle generating a report on a repository with no open issues.
  ([#92](https://github.com/how-is/how_is/pull/92))
- Add Rake tasks to make development easier. ([#86](https://github.com/how-is/how_is/pull/86), [#94](https://github.com/how-is/how_is/pull/94), [#96](https://github.com/how-is/how_is/pull/96))
- PR/issue info is now displayed as lists instead of paragraphs. ([#83](https://github.com/how-is/how_is/pull/83))

## [11.0.0]

This release ([snapshot](https://github.com/how-is/how_is/tree/v11.0.0))
removed PDF reports, handles more edge cases, and improves tests.

### Added

- Document Ruby API

### Changed

- Fixed command-line help text (it was incorrect in v10.0.0 and some earlier versions)
- Handles generating reports for repositories with no issues and/or no PRs
- Handles generating reports for repositories with no activity in the
  past month
- Tests are improved
- Tests no longer make actual network requests

### Removed

- PDF reports

## [10.0.0 and earlier]

This changelog was started while working on v11.0.0.
Prior to that, I have no idea what was added or when.
