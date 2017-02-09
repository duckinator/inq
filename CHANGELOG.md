# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com) and
this project adheres to [Semantic Versioning](http://semver.org).

## [Unreleased]

(Nothing so far.)

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
