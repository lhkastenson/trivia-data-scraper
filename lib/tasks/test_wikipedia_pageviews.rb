require "httparty"
require "date"

class WikipediaPageviewTester

  BASE_URL = "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article"

  YEAR_MONTHS = 12

  def test_people
    test_cases = [
      "Tom_Hanks",
      "Taylor_Swift",
      "Donald_Trump",
      "LeBron_James",
      "Barack_Obama",
      "Meryl_Streep",
      "Keanu_Reeves",
      "Morgan_Freeman",
      "Jennifer_Lawrence",
      "SOME_RANDOM_NAME_NO_RESULTS"
    ]

    puts "Testing wikipedia pageviews (12 month average)\n\n"

    test_cases.each do |person|
      views = get_annual_average_pageviews(person)
      puts "#{person.gsub("_", " ")}: #{views ? number_with_delimiter(views): "NOT FOUND"} avg views/month"
    end
  end

  def get_annual_average_pageviews(article_name)
    end_date = Date.today
    start_date = end_date << YEAR_MONTHS

    url = "#{BASE_URL}/en.wikipedia/all-access/user/#{article_name}/monthly/#{start_date.strftime("%Y%m%d")}00/#{end_date.strftime("%Y%m%d")}00"

    response = HTTParty.get(url)

    if response.code == 200
      data = response.parsed_response
      items = data["items"] || []
      return nil if items.empty?

      total_views = items.sum { |item| item["views"] }
      (total_views / items.length.to_f).round
    else
      nil
    end
  rescue => e
    puts "  Error for #{artcile_name}: #{e.message}"
    nil
  end

  private

  def number_with_delimiter(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end

WikipediaPageviewTester.new.test_people