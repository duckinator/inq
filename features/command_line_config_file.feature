Feature: Command line
  Scenario: running `how_is with a config file
    Given a file named "how_is.yml" with:
    """
    repository: rubygems/rubygems
    reports:
      html:
        directory: .
        frontmatter:
          title: "%{repository} report"
          layout: default
        filename: "report.html"
      json:
        directory: json
        filename: "report.json"
    """
    And I successfully run `bundle exec how_is --config`
    Then the file "report.html" should contain:
    """
    ---
    title: rubygems/rubygems report
    layout: default
    ---
    """
