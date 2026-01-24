require "httparty"
require "date"
require "active_support/core_ext/integer/time"

class WikipediaCategoryTester
  PAGEVIEWS_URL = "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article"
  CATEGORY_URL = "https://en.wikipedia.org/w/api.php"
  SAMPLE_SIZE = 10  # Sample 10 people per category

  def test_categories
    categories = [
      "American_male_film_actors",
      "American_film_actresses",
      "American_music_people",
      "American_politicians",
      "Olympic_athletes"
    ]

    puts "Sampling Wikipedia categories for popularity...\n\n"

    categories.each do |category|
      puts "=" * 60
      puts "Category: #{category.gsub('_', ' ')}"
      puts "=" * 60

      sample_category(category)
      puts "\n"
    end
  end

  private

  def sample_category(category)
    # Get pages from category
    response = HTTParty.get(CATEGORY_URL, query: {
      action: "query",
      list: "categorymembers",
      cmtitle: "Category:#{category}",
      cmlimit: 50,  # Get 50 to sample from
      format: "json"
    })

    members = response.dig("query", "categorymembers") || []

    if members.empty?
      puts "  No members found!"
      return
    end

    puts "  Total in category: ~#{members.count}+ (showing #{SAMPLE_SIZE} samples)\n\n"

    # Sample random people
    sample = members.sample(SAMPLE_SIZE)
    pageviews = []

    sample.each do |member|
      title = member["title"]
      views = get_annual_average_pageviews(title)

      if views
        pageviews << views
        puts "  #{title}: #{number_with_delimiter(views)} avg views/month"
      else
        puts "  #{title}: NO DATA"
      end

      sleep(0.1)  # Rate limiting
    end

    if pageviews.any?
      puts "\n  Stats:"
      puts "    Min: #{number_with_delimiter(pageviews.min)}"
      puts "    Max: #{number_with_delimiter(pageviews.max)}"
      puts "    Avg: #{number_with_delimiter(pageviews.sum / pageviews.length)}"
      puts "    Median: #{number_with_delimiter(pageviews.sort[pageviews.length / 2])}"
    end
  end

  def get_annual_average_pageviews(article_name)
    # Remove "User:" or "Talk:" prefixes if present
    article_name = article_name.split(":").last

    end_date = Date.today.beginning_of_month
    start_date = end_date << 12

    url = "#{PAGEVIEWS_URL}/en.wikipedia/all-access/user/#{article_name.gsub(' ', '_')}/monthly/#{start_date.strftime('%Y%m%d')}00/#{end_date.strftime('%Y%m%d')}00"

    response = HTTParty.get(url)

    if response.code == 200
      items = response.dig("items") || []
      return nil if items.empty?

      total_views = items.sum { |item| item["views"] }
      (total_views / items.length.to_f).round
    else
      nil
    end
  rescue => e
    nil
  end

  def number_with_delimiter(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end

WikipediaCategoryTester.new.test_categories
