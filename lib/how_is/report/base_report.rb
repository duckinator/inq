module HowIs
  ##
  # Subclasses of BaseReport represent complete reports.
  class BaseReport < Struct.new(:analysis)
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

    def export(&block)
      raise NotImplementedError
    end

    def export_file(file, &block)
      raise NotImplementedError
    end

    def to_h
      analysis.to_h
    end
    alias :to_hash :to_h

    def to_json
      to_h.to_json
    end

    private
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
      oldest_date_format = "%b %e, %Y"
      a = analysis

      number_of_type = a.send("number_of_#{type}s")

      type_link = a.send("#{type}s_url")
      oldest = a.send("oldest_#{type}")

      if number_of_type == 0
        text "There are #{link("no #{type_label}s open", type_link)}."
      else
        text "There #{are_is(number_of_type)} #{link("#{number_of_type} #{pluralize(type_label, number_of_type)} open", type_link)}."
        unordered_list [
          "Average age: #{a.send("average_#{type}_age")}.",
          "#{link('Oldest ' + type_label, oldest['html_url'])} was opened on #{oldest['date'].strftime(oldest_date_format)}.",
        ]
      end
    end
  end
end
