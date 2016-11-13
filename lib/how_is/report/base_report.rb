module HowIs
  ##
  # Subclasses of BaseReport represent complete reports.
  class BaseReport < Struct.new(:analysis)
    def format
      raise NotImplementedError
    end

    def github_pulse_summary
      @pulse ||= HowIs::Pulse.new(analysis.repository)
      @pulse.send("#{format}_summary")
    end

    def to_h
      analysis.to_h
    end
    alias :to_hash :to_h

    def to_json
      to_h.to_json
    end

    private
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
        "There are #{link("no #{type_label}s open", type_link)}."
      else
        "There #{are_is(number_of_type)} #{link("#{number_of_type} #{pluralize(type_label, number_of_type)} open", type_link)}. " +
        "The average #{type_label} age is #{a.send("average_#{type}_age")}, and the " +
        "#{link("oldest", oldest['html_url'])} was opened on #{oldest['date'].strftime(oldest_date_format)}."
      end
    end
  end
end
