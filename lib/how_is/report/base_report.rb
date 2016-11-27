require 'json'

module HowIs
  ##
  # Subclasses of BaseReport represent complete reports.
  class BaseReport < Struct.new(:analysis)
    def generate_report_text!
      title "How is #{analysis.repository}?"

      # DateTime#new_offset(0) sets the timezone to UTC. I think it does this
      # without changing anything besides the timezone, but who knows, 'cause
      # new_offset is entirely undocumented! (Even though it's used in the
      # DateTime documentation!)
      #
      # TODO: Stop pretending everyone who runs how_is is in UTC.
      text "Monthly report, ending on #{DateTime.now.new_offset(0).strftime('%B %e, %Y')}."

      text github_pulse_summary

      header "Pull Requests"
      issue_or_pr_summary "pull", "pull request"

      header "Issues"
      issue_or_pr_summary "issue", "issue"

      header "Issues Per Label"
      issues_per_label = analysis.issues_with_label.to_a.sort_by { |(k, v)| v['total'].to_i }.reverse
      issues_per_label.map! do |label, hash|
        [label, hash['total'], hash['link']]
      end
      issues_per_label << ["(No label)", analysis.issues_with_no_label['total'], nil]
      horizontal_bar_graph issues_per_label
    end


    
    def format
      raise NotImplementedError
    end

    def title(_text)
      raise NotImplementedError
    end

    def header(_text)
      raise NotImplementedError
    end

    def text(_text)
      raise NotImplementedError
    end

    def link(_text, url)
      raise NotImplementedError
    end

    def unordered_list(arr)
      raise NotImplementedError
    end

    def horizontal_bar_graph(data)
      raise NotImplementedError
    end

    def monthly_summary
      raise NotImplementedError
    end

    def export
      raise NotImplementedError
    end

    def export_file(file)
      raise NotImplementedError
    end

    def to_h
      analysis.to_h
    end
    alias :to_hash :to_h

    def to_json
      JSON.pretty_generate(to_h)
    end

    private
    def categorize_labels(labels)
      categories = {}
      labels.each do |label, hash|
        parts = label.split(':', 2)
        if parts.length == 1
          category = :none
        else
          category = parts.first
        end

        categories[category] ||= {}
        categories[category][label] = hash
      end

      categories
    end

    def sort_labels_in_category(category)
      #...
    end

    def sort_categories(categories)
      #...
    end

    def github_pulse_summary
      @pulse ||= HowIs::Pulse.new(analysis.repository)
      @pulse.send("#{format}_summary")
    end

    def pluralize(text, number)
      number == 1 ? text : "#{text}s"
    end

    def are_is(number)
      number == 1 ? "is" : "are"
    end

    def issue_or_pr_summary(type, type_label)
      date_format = "%b %e, %Y"
      a = analysis

      number_of_type = a.send("number_of_#{type}s")

      type_link = a.send("#{type}s_url")
      oldest = a.send("oldest_#{type}")
      newest = a.send("newest_#{type}")

      if number_of_type == 0
        text "There are #{link("no #{type_label}s open", type_link)}."
      else
        text "There #{are_is(number_of_type)} #{link("#{number_of_type} #{pluralize(type_label, number_of_type)} open", type_link)}."

        unordered_list [
          "Average age: #{a.send("average_#{type}_age")}.",
          "#{link('Oldest ' + type_label, oldest['html_url'])} was opened on #{oldest['date'].strftime(date_format)}.",
          "#{link('Newest ' + type_label, newest['html_url'])} was opened on #{newest['date'].strftime(date_format)}.",
        ]
      end
    end
  end
end
