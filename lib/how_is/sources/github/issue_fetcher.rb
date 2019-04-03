# frozen_string_literal: true

require "how_is/version"
require "how_is/date_time_helpers"
require "how_is/sources/github"
require "how_is/text"

module HowIs
  module Sources
    class Github
      ##
      # Fetches raw data for GitHub issues.
      class IssueFetcher
        include HowIs::DateTimeHelpers

        END_LOOP = :terminate_graphql_loop

        GRAPHQL_QUERY = <<~QUERY
          repository(owner: %{user}, name: %{repo}) {
            %{type}(first: %{chunk_size}%{after_str}, orderBy:{field: CREATED_AT, direction: ASC}) {
              edges {
                cursor
                node {
                  number
                  createdAt
                  closedAt
                  updatedAt
                  state
                  title
                  url
                  labels(first: 100) {
                    nodes {
                      name
                    }
                  }
                }
              }
            }
          }
        QUERY

        CHUNK_SIZE = 100

        attr_accessor :type

        def initialize(config, type, start_date, end_date, cache)
          @config = config
          @cache = cache
          @github = HowIs::Sources::Github.new(config)
          @repository = config["repository"]
          @user, @repo = @repository.split("/", 2)
          @start_date = start_date
          @end_date = end_date
          @type = type
        end

        def data
          return @data if instance_variable_defined?(:@data)

          @data = []
          return @data if last_cursor.nil?

          HowIs::Text.print "Fetching #{@repository} #{(type == 'issues') ? 'issue' : 'PR'} data."

          data = @cache.cached(type) do
            data = []
            after = nil
            after, data = fetch_issues(after, data) until after == END_LOOP
            data
          end

          HowIs::Text.puts

          @data = data.select(&method(:issue_is_relevant?))
        end

        def issue_is_relevant?(issue)
          if !issue["closedAt"].nil? && date_le(issue["closedAt"], @start_date)
            false
          else
            date_ge(issue["createdAt"], @start_date) && date_le(issue["createdAt"], @end_date)
          end
        end

        def last_cursor
          return @last_cursor if instance_variable_defined?(:@last_cursor)

          raw_data = @github.graphql <<~QUERY
            repository(owner: #{@user.inspect}, name: #{@repo.inspect}) {
              #{type}(last: 1, orderBy:{field: CREATED_AT, direction: ASC}) {
                edges {
                  cursor
                }
              }
            }
          QUERY

          edges = raw_data.dig("data", "repository", type, "edges")
          @last_cursor =
            if edges.nil? || edges.empty?
              nil
            else
              edges.last["cursor"]
            end
        end

        def fetch_issues(after, data)
          HowIs::Text.print "."

          after_str = ", after: #{after.inspect}" unless after.nil?

          query = build_query(@user, @repo, type, after_str)
          raw_data = @github.graphql(query)
          edges = raw_data.dig("data", "repository", type, "edges")

          data += edge_nodes(edges)

          next_cursor = edges.last["cursor"]
          next_cursor = END_LOOP if next_cursor == last_cursor

          [next_cursor, data]
        end

        def build_query(user, repo, type, after_str)
          format(GRAPHQL_QUERY, {
            user: user.inspect,
            repo: repo.inspect,
            type: type,
            chunk_size: CHUNK_SIZE,
            after_str: after_str,
          })
        end

        def edge_nodes(edges)
          return [] if edges.nil?
          new_data = edges.map { |issue|
            node = issue["node"]
            node["labels"] = node["labels"]["nodes"]

            node
          }

          new_data
        end
      end
    end
  end
end
