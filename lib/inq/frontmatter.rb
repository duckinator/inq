# frozen_string_literal: true

require "inq/version"
require "okay/warning_helpers"

module Inq
  ##
  # Module for generating YAML frontmatter, as used by Jekyll and other
  # blog engines.
  module Frontmatter
    extend Okay::WarningHelpers

    # Generates YAML frontmatter, as is used in Jekyll and other blog engines.
    #
    # E.g.,
    #     generate_frontmatter({'foo' => "bar %{baz}"}, {'baz' => "asdf"})
    # =>  "---\nfoo: bar asdf\n"
    #
    # @param frontmatter [Hash] Frontmatter for the report.
    # @param report_data [Hash] The report data itself.
    # @return [String] A YAML dump of the generated frontmatter.
    def self.generate(frontmatter, report_data)
      return "" if frontmatter.nil?

      frontmatter = convert_keys(frontmatter, :to_s)
      report_data = convert_keys(report_data, :to_sym)

      frontmatter = frontmatter.map { |k, v|
        # Sometimes report_data has unused keys, which generates a warning, but
        # we're okay with it.
        v = silence_warnings { v % report_data }

        [k, v]
      }.to_h

      YAML.dump(frontmatter) + "---\n\n"
    end

    # @example
    #   convert_keys({'foo' => 'bar'}, :to_sym)
    #   # => {:foo => 'bar'}
    # @param data [Hash] The input hash.
    # @param method_name [Symbol] The method name used to convert keys.
    #   (E.g. :to_s, :to_sym, etc.)
    # @return [Hash] The converted result.
    def self.convert_keys(data, method_name)
      data.map { |k, v| [k.send(method_name), v] }.to_h
    end
    private_class_method :convert_keys
  end
end
