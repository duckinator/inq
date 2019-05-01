[![Travis](https://img.shields.io/travis/duckinator/inq.svg)](https://travis-ci.org/duckinator/inq)
[![Code Climate](https://img.shields.io/codeclimate/github/duckinator/inq.svg)](https://codeclimate.com/github/duckinator/inq)
[![Gem](https://img.shields.io/gem/v/inq.svg)](https://rubygems.org/gems/inq)
[Documentation](https://how-is.github.io)

# Inq

Inq is tool for generating summaries of the health of a codebase hosted on GitHub. It uses information available from issues and pull requests to provide an overview of a repository and highlight problem areas of the codebase.

Reports can be generated retroactively.

If you want to contribute or discuss inq, you can [join Bundler's slack](http://slack.bundler.io/) and join the #how_is channel.

## Installation

    $ gem install inq

## Configuration

To avoid errors due to hitting rate limits, Inq requires a Personal
Access Token for GitHub.

### Acquiring A Personal Access Token

To acquire a personal access token:

1. Go to: https://github.com/settings/tokens/new
2. For `Token description`, enter `inq CLI client`.
3. Scroll to the bottom of the page.
4. Click `Generate token`. This will take you to a new page.
5. Save the token somewhere. **You can't access it again.**

**NOTE:** Inq _only_ needs read access.

#### Using The Token

Create a file in `~/.config/inq/config.yml`:

```
sources/github:
  username: <USERNAME>
  token:    <TOKEN>
```

Make sure to replace `<TOKEN>` with the actual token, and `<USERNAME>`
with your GitHub username.

## Usage

### Command Line

    $ inq --repository REPOSITORY --date DATE [--output OUTPUT_FILENAME]
    # OUTPUT_FILENAME defaults to ./report.html.

or

    $ inq --date DATE --config CONFIG_FILENAME

#### Example \#1

    $ inq rubygems/rubygems 2016-12-01 --output report-2016-12-01.html

The above command creates a HTML file containing the report for the state of
the rubygems/rubygems repository, for November 01 2016 to
December 01 2016, and saves it as `./report-2016-12-01.html`.

#### Example \#2

    $ inq --date 2016-12-01 --config some-config.yml

This generates the report(s) specified in the config file, for the period
from November 01 2016 to December 01 2016, and saves them in the
locations specified in the config file.

#### Screenshot

![image](https://user-images.githubusercontent.com/211/55504154-89284180-5650-11e9-9a13-e03e9b83c749.png)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec inq` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/duckinator/inq. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
