require 'spec_helper'
require 'json'

describe HowBad::Fetcher do
  github = instance_double('GitHub',
            issues: instance_double('GitHub::Issues', list: JSON.parse(open('../data/issues.json'))),
            pulls: instance_double('GitHub::Pulls', list: JSON.parse(open('../data/pulls.json')))
            )
end
