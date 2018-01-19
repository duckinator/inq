[![Waffle.io](https://img.shields.io/waffle/label/how-is/how_is/in%20progress.svg)](https://waffle.io/how-is/how_is)
[![Travis](https://img.shields.io/travis/how-is/how_is.svg)](https://travis-ci.org/how-is/how_is)
[![Code Climate](https://img.shields.io/codeclimate/github/how-is/how_is.svg)](https://codeclimate.com/github/how-is/how_is)
[![Gem](https://img.shields.io/gem/v/how_is.svg)](https://rubygems.org/gems/how_is)
[![Gemnasium](https://img.shields.io/gemnasium/how-is/how_is.svg)](https://gemnasium.com/github.com/how-is/how_is)

# How is [your repo]?

`how_is` is tool for generating summaries of the health of a codebase hosted on GitHub. It uses information available from issues and pull requests to provide an overview of a repository and highlight problem areas of the codebase.

Reports can be generated retroactively.

If you want to contribute or discuss how_is, you can [join Bundler's slack](http://slack.bundler.io/) and join the #how_is channel.

## Installation

    $ gem install how_is

## Usage

### Command Line

    $ how_is REPOSITORY DATE [--output OUTPUT_FILENAME]
    # OUTPUT_FILENAME defaults to ./report.html.

or

    $ how_is REPOSITORY --config CONFIG_FILENAME


#### Example \#1

    $ how_is rubygems/rubygems 2016-12-01 --output report-2016-12-01.html

The above command creates a HTML file containing the report for the state of
the rubygems/rubygems repository, for November 01 2016 to
December 01 2016, and saves it as `./report-2016-12-01.html`.

#### Example \#2

    $ how_is 2016-12-01 --config some-config.yml

Generates the report(s) specified in the config file, for the period
from November 01 2016 to December 01 2016, and saves them in the
locations specified in the config file.

#### Generating reports from a config file

You can also create a config file and run
`how_is --config YAML_CONFIG_FILE_PATH`.

E.g., if the config file is `how_is.yml`, you would run
`how_is --config how_is.yml`.

Below is an example config file, [from the how-is/manual-reports
repository](https://raw.githubusercontent.com/how-is/manual-reports/gh-pages/how-is-configs/01-rubygems-rubygems.yml).

```yaml
repository: rubygems/rubygems
reports:
  html:
    directory: rubygems/_posts
    frontmatter:
      title: "%{date} Report"
      layout: default
    filename: "%{date}-report.html"
  json:
    directory: json/rubygems
    filename: "%{date}.json"
```

The config file is a YAML file. The two root keys are `repository`
and `reports`.

`reports` is a hash of key/value pairs, with the keys being the type of report
("html" or "json") and the values being another hash.

That hash can have the following keys: `directory` (the directory to place the
report in), `filename` (the format string for filenames), and (optionally)
`frontmatter`.

`frontmatter` is a set of key/value pairs specifying frontmatter as used by
various blog engines (e.g. Jekyll), so you can set the title, layout, etc of
the page.

Every value under `reports` is a format string, so you can do e.g.
`filename: "%{date}-report.html"` or (under `frontmatter`)
`title: "%{date} Report"`.

### Ruby API

```ruby
# Generate an HTML report for rubygems/rubygems, for December 01
# 2017, and save it to report.html:
report = HowIs.new("rubygems/rubygems", "2017-12-01").to_html
report.save_as("report.html")

# Generate a report from a config Hash.
reports = HowIs.from_config({
  repository: 'rubygems/rubygems',
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
}, "2017-12-01")
# Save all of the rports.
# This assumes all of the directories the files go in already exist!
reports.map {|file, report| File.write(file, report) }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec how_is` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/how-is/how_is. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
