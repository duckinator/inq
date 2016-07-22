require 'how_is'
require 'yaml'

class HowIs::CLI
  DEFAULT_CONFIG_FILE = 'how_is.yml'

  def generate_frontmatter(frontmatter, report_data)
    frontmatter = frontmatter.map { |k, v|
      v = v % report_data

      [k, v]
    }.to_h

    YAML.dump(frontmatter)
  end

  def from_config_file(config_file = nil)
    config_file ||= DEFAULT_CONFIG_FILE

    from_config(YAML.load_file(config_file))
  end

  def from_config(config)
    date = Date.strptime(Time.now.to_i.to_s, '%s')
    date_string = date.strftime('%Y-%m-%d')
    friendly_date = date.strftime('%B %d, %y')

    analysis = HowIs.generate_analysis(repository: config['repository'])

    report_data = {
      repository: config['repository'],
      date: date,
      friendly_date: friendly_date,
    }

    config['reports'].each do |format, report_config|
      filename = report_config['filename'] % report_data
      file = File.join(report_config['directory'], filename)

      report = HowIs::Report.export(analysis, format)

      File.open(file, 'w') do |f|
        if report_config['frontmatter']
          f.puts generate_frontmatter(report_config['frontmatter'], report_data)
          f.puts "---"
          f.puts
        end

        f.puts report
      end
    end
  end
end
