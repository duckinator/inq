[![Waffle.io](https://img.shields.io/waffle/label/how-is/how_is/in%20progress.svg)](https://waffle.io/how-is/how_is)
[![Travis](https://img.shields.io/travis/how-is/how_is.svg)](https://travis-ci.org/how-is/how_is)
[![Code Climate](https://img.shields.io/codeclimate/github/how-is/how_is.svg)](https://codeclimate.com/github/how-is/how_is)
[![Gem](https://img.shields.io/gem/v/how_is.svg)](https://rubygems.org/gems/how_is)
[Documentation](https://how-is.github.io)

# How is [your project]?

`how_is` is tool for generating summaries of the health of a codebase hosted on GitHub. It uses information available from issues and pull requests to provide an overview of a repository and highlight problem areas of the codebase.

Reports can be generated retroactively.

If you want to contribute or discuss how_is, you can [join Bundler's slack](http://slack.bundler.io/) and join the #how_is channel.

## Installation

    $ gem install how_is

## Configuration

To avoid errors due to hitting rate limits, HowIs requires a Personal
Access Token for GitHub.

### Acquiring A Personal Access Token

To acquire a personal access token:

1. Go to: https://github.com/settings/tokens/new
2. For `Token description`, enter `how_is CLI client`.
3. Scroll to the bottom of the page.
4. Click `Generate token`. This will take you to a new page.
5. Save the token somewhere. **You can't access it again.**

**NOTE:** HowIs _only_ needs read access.

#### Using The Token

Create a file in `~/.config/how_is/config.yml`:

```
sources/github:
  username: <USERNAME>
  token:    <TOKEN>
```

Make sure to replace `<TOKEN>` with the actual token, and `<USERNAME>`
with your GitHub username.

## Usage

### Command Line

    $ how_is --repository REPOSITORY --date DATE [--output OUTPUT_FILENAME]
    # OUTPUT_FILENAME defaults to ./report.html.

or

    $ how_is --date DATE --config CONFIG_FILENAME

#### Example \#1

    $ how_is rubygems/rubygems 2016-12-01 --output report-2016-12-01.html

The above command creates a HTML file containing the report for the state of
the rubygems/rubygems repository, for November 01 2016 to
December 01 2016, and saves it as `./report-2016-12-01.html`.

#### Example \#2

    $ how_is --date 2016-12-01 --config some-config.yml

This generates the report(s) specified in the config file, for the period
from November 01 2016 to December 01 2016, and saves them in the
locations specified in the config file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec how_is` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/how-is/how_is. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
