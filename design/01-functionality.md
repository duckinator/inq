# how_is functional specification

By [Ellen Marie Dash](https://twitter.com/duckinator)
Last Updated: 2017-01-03

This document is a _functional specification_ (in other words, it documents
how the program works from an end-user perspective).
See [02-implementation.md](02-implementation.md) for a technical
specification (that is, how it is implemented).

*This document is incomplete.* It will take significant revisions before
this document can be considered complete.

## Overview

how_is is a command-line tool to quantify the state of a GitHub
repository, and suggest actionable tasks to improve maintenance. It uses
information from the issue tracker, the codebase itself, and third-party
APIs to accomplish this. The expected audience is project managers, or
people in similar roles, and software developers.

## Scenarios

When designing products, it helps to imagine a few real life stories of
how actual (stereotypical) people would use them. Let's look at some
scenarios.

### Scenario 1: Jill (Project Manager)

Jill is a project manager for a large software project, which is hosted
on GitHub. She recently realized the project is falling behind on
managing issues and pull requests, and would like to get more detailed
information about this.

She runs `how_is some_org/some_project` to generate a report, which
contains information about the oldest and newest issues/PRs, the rate at
which issues/PRs are being opened and closed, and what issues fall under
whiat label. It also includes suggestions for improving management of
the project &mdash; such as possible approaches to keep on top of new
pull requests.

### Scenario 2: Jesse (Developer)

Jesse is a developer who works on the same project as Jill.
??? Why do people use a config file? It feels like it may actually
be redundant after the dashboard is implemented? Maybe we should discuss
the Ruby API instead? ???

## Nongoals

This project is not:

* A dashboard. It generates a static report. However, a dashboard is
  going to be implemented _using_ how\_is. See:
  [how-is/dashboard](https://github.com/how-is/dashboard).
* Magic. It can at best give suggestions based on data. It can't know
  the context or nuance to provide tailored advice. It needs human
  interpretation and understanding in order to be useful.

## Contents of a Report

Reports will contain the following:

* Number of open issues/PRs (+ links to listing of open issues/PRs).
* Links to newest and oldest issues/PRs + dates they were opened.
* Average issue/PR age.
* Number of issues closed in the past month (+ link to GitHub page listing
  them).\*
* Number of PRs merged in the past month (+ link to GitHub page listing
  them).\*
* Number of issues/PRs not updated in the past month (+ link to GitHub
  page listing them, if possible).\*
* A graph showing the number of issues with each label (grouped by
  category &mdash; explained later), as well as with no label (+ links
  to lists of issues with each label).\*\*
  * Clicking a label will pull information about issue labels from
    various files, if they exist. Assuming one of those files exists,
    clicking on a label will show the description of that label if it is
    defined. If it is not defined, it will show a message explaining
    that. The description will include a link to the file it was pulled
    from.\*
* Code churn (via Code Climate) &mdash; TODO: determine presentation
  details.\*
* Average length of time it takes for any team member to respond to a
  new issue/PR.\*
  * If a directory containing previous reports is specified, generate a
    graph of this response time per week.\*

Items with an asterisk (\*) have yet to be implemented.
Items with two asterisks (\*\*) have been partially implemented.

## UI Specification

TODO: Specify how the UI works.

