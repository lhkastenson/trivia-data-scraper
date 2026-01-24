require "httparty"
require "date"
require "active_support/core_ext/integer/time"

class VitalArticlesTester
  PAGEVIEWS_URL = "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article"
  WIKI_API_URL = "https://en.wikipedia.org/w/api.php"
  WIKIPEDIA_RATE_LIMIT = 0.1
  YEAR_MONTHS = 12
  PAGEVIEW_THRESH = 50_000

  def test_level_3_people
    puts "Fetching Level 4 Vital Articles - People\n\n"

    people_list = get_vital_articles_people

    puts "Found #{people_list.count} people in Level 4 vital articles\n\n"

    qualified_people = []

    people_list.each_with_index do |person_name, index|
      views = get_annual_average_pageviews(person_name)

      if views && views >= PAGEVIEW_THRESH
        qualified_people << { name: person_name, views: views }
      end

      sleep(WIKIPEDIA_RATE_LIMIT)
    end

    puts "Results:"
    puts "  Total Level 4 people: #{people_list.count}"
    puts "  People with #{PAGEVIEW_THRESH}+ views: #{qualified_people.count}"

    sample = qualified_people.sample([ 20, qualified_people.count ].min)

    puts "\nTop 20 by popularity:"
    sample.sort_by { |p| -p[:views] }.first(20).each do |person|
      puts "  #{person[:name]}: #{format_number(person[:views])}"
    end

    # Stats
    views = qualified_people.map { |p| p[:views] }
    if views.any?
      puts "\nStats for #{THRESHOLD}+ threshold:"
      puts "  Min: #{format_number(views.min)}"
      puts "  Max: #{format_number(views.max)}"
      puts "  Avg: #{format_number(views.sum / views.length)}"
      puts "  Median: #{format_number(views.sort[views.length / 2])}"
    end
  end

  private

  def get_vital_articles_people
    page_title = "Wikipedia:Vital_articles/Level/4/People"

    response = HTTParty.get(WIKI_API_URL, query: {
      action: "parse",
      page: page_title,
      prop: "links",
      format: "json"
    })

    links = response.dig("parse", "links") || []

    people = links
      .select { |link| link["ns"] == 0 }
      .map { |link| link["*"] }
      .reject { |name| name.start_with?("Wikipedia:", "User:", "Talk:") }

    people
  end

  def get_annual_average_pageviews(article_name)
    end_date = Date.today.beginning_of_month
    start_date = end_date << 12

    # Properly encode URL
    encoded_name = URI.encode_www_form_component(article_name.gsub(" ", "_"))

    url = "#{PAGEVIEWS_URL}/en.wikipedia/all-access/user/#{encoded_name}/monthly/#{start_date.strftime('%Y%m%d')}00/#{end_date.strftime('%Y%m%d')}00"

    headers = {}
    if ENV["WIKIPEDIA_ACCESS_TOKEN"]
      headers["Authorization"] = "Bearer #{ENV["WIKIPEDIA_ACCESS_TOKEN"]}"
    end

    response = HTTParty.get(url, headers: headers)

    if response.code == 200
      items = response.dig("items") || []
      return nil if items.empty?

      total_views = items.sum { |item| item["views"] }
      (total_views / items.length.to_f).round
    else
      puts "  API returned #{response.code} for #{article_name}"
      nil
    end
  rescue => e
    puts "  Exception for #{article_name}: #{e.class} - #{e.message}"
    nil
  end

  def number_with_delimiter(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end

VitalArticlesTester.new.test_level_3_people
