[![Stories in Ready](https://badge.waffle.io/duckinator/how_is.png?label=ready&title=Ready)](https://waffle.io/duckinator/how_is)
[![Build Status](https://travis-ci.org/duckinator/how_is.svg?branch=master)](https://travis-ci.org/duckinator/how_is)

# How is [your repo]?

`how_is` is tool for generating summaries of the health of a codebase. It uses information available from issues and pull requests to provide an overview of a repository and highlight problem areas of the codebase.

The summary includes:

* repository name,
* number of open issues,
* number of open pull requests,
* number of open issues associated with each label and with no label,
* average issue age,
* average pull request age,
* date oldest issue was opened,
* date oldest pull request was opened.

If you want to contribute or discuss how_is, you can [join Bundler's slack](http://slack.bundler.io/) and join the #how_is channel.

## Installation

    $ gem install how_is

## Usage

### Command Line

    $ how_is <orgname>/<reponame> [--report FILENAME]

E.g.,

    $ how_is rubygems/rubygems --report report.html

The above command creates a HTML file containing the summary at `./report.html`.

#### Generating reports from a config file

Beyond the above, you can also create a config file &mdash; typically called
how_is.yml &mdash; and run `how_is --config YAML_CONFIG_FILE`. If your config
file is called how_is.yml, you can just run `how_is --config`.

You can see [the how_is.yml in the how-is-rubygems repository](https://github.com/how-is/how-is-rubygems/blob/gh-pages/how_is.yml)
for an example.

The config file is a YAML file. The two root keys are `repository` (the
repository name, of format USER_OR_ORG/REPOSITORY &mdash; e.g. how-is/how_is)
and `reports`.

`reports` is a hash of key/value pairs, with the keys being the type of report
("html", or "json") and the values being another hash.

That hash can have the following keys: `directory` (the directory to place the
report in), `filename` (the format string for filenames), and (optionally)
`frontmatter`.

`frontmatter` is a set of key/value pairs specifying frontmatter as used by
various blog engines (e.g. Jekyll), so you can set title, layout, etc.

Every value under `reports` is a format string, so you can do e.g.
`filename: "%{date}-report.html"` or (under `frontmatter`)
`title: "%{date} Report"`.

### Ruby API

```ruby
# Generate a report for <orgname>/<reponame>, defaulting to
# the report file being report.html.
HowIs.generate_report(repository: '<orgname>/<reponame>')

# Generate a report for <orgname>/<reponame>, specifying
# a report file of blah-report.html.
HowIs.generate_report(repository: '<orgname>/<reponame>', report:
'blah-report.html')

# Generate a report from a config file located at ./how_is.yml.
# Example config file: https://github.com/how-is/how-is-rubygems/blob/gh-pages/how_is.yml
# NOTE: This is going to be moved outside of HowIs::CLI at some point.
HowIs::CLI.new.from_config_file('how_is.yml')

# Generate a report from a config Hash.
# NOTE: This is going to be moved outside of HowIs::CLI at some point.
HowIs::CLI.new.from_config({
  repository: '<orgname>/<reponame>',
  reports: {
    html: {
      directory: '_posts',
      frontmatter: {
        title: '%{date} Report',
        layout: 'default'
      },
      filename: "%{date}-report.html"
    },
    json: {
      directory: 'json',
      filename: '%{date}.json'
    }
  }
})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec how_is` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/duckinator/how_is. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
