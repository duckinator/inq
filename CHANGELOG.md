# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com) and
this project adheres to [Semantic Versioning](http://semver.org).

## [Unreleased]

(Nothing so far.)

## [v12.0.0]

This release largely focused on refactoring and developer experience
improvements (e.g. adding Rake tasks and improving the generated JSON and HTML).

Pull Requests for this release can be [viewed on
GitHub](https://github.com/how-is/how_is/pulls?utf8=&q=is%3Apr%20created%3A2016-11-11..2016-12-10).

### Added

- Include newest PR/issue in reports.
  ([#85](https://github.com/how-is/how_is/pull/85)).

### Changed

- JSON and HTML reports have nicer source.
  ([#82](https://github.com/how-is/how_is/pulls/82),
  [#84](https://github.com/how-is/how_is/pulls/84)).
- Handle generating a report on a repository with no open issues.
  ([#92](https://github.com/how-is/how_is/pull/92)).

## [11.0.0]

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
