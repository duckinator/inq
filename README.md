[![Stories in Ready](https://badge.waffle.io/duckinator/how_is.png?label=ready&title=Ready)](https://waffle.io/duckinator/how_is)
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

## Installation

    $ gem install how_is

## Usage

    $ how_is <orgname>/<reponame> [--report-file FILENAME]

E.g.,

    $ how_is rubygems/rubygems --report-file report.pdf

The above command creates a PDF containing the summary at `./report.pdf`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec how_is` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/duckinator/how_is. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
