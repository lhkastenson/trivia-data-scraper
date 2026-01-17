class TmdbTvScraper
  include HTTParty
  base_uri "https://api.themoviedb.org/3"

  DECADE_THRESHOLDS = {
    (1960..1969) => 200,
    (1970..1979) => 200,
    (1980..1989) => 300,
    (1990..1999) => 500,
    (2000..2009) => 750,
    (2010..2019) => 1_000,
    (2020..2029) => 700
  }.freeze

  RATE_LIMIT_TIME = 0.25

  def initialize
    @api_key = ENV["TMDB_API_KEY"]
  end

  def scrape_tv_shows
    DECADE_THRESHOLDS.each do |decade_range, vote_threshold|
      puts "Scraping #{decade_range.first}-#{decade_range.last} (vote count >= #{vote_threshold})"

      page = 1
      loop do
        data = get_tv_shows_page(
          page: page,
          year_min: decade_range.first,
          year_max: decade_range.last,
          vote_count_min: vote_threshold
        )

        break if data["results"].empty?

        data["results"].each do |show_data|
          save_tv_show(show_data)
        end

        puts "   Page #{page}/#{data['total_pages']} - #{data['results'].size} shows"

        break if page >= data["total_pages"]
        page += 1

        sleep(RATE_LIMIT_TIME)
      end
    end
  end

  private

  def get_tv_shows_page(page:, year_min:, year_max:, vote_count_min:)
    response = self.class.get("/discover/tv", query: {
      api_key: @api_key,
      page: page,
      "first_air_date.gte" => "#{year_min}-01-01",
      "first_air_date.lte" => "#{year_max}-12-31",
      "vote_count.gte" => vote_count_min,
      sort_by: "popularity.desc"
    })

    response.parsed_response
  end

  def save_tv_show(show_data)
    TvShow.find_or_create_by(tmdb_id: show_data["id"]) do |show|
      show.title = show_data["name"]
      show.year = show_data["first_air_date"]&.split("-")&.first&.to_i
      show.popularity = show_data["popularity"]
      show.vote_count = show_data["vote_count"]
      show.vote_average = show_data["vote_average"]
      show.overview = show_data["overview"]
      show.genres = show_data["genre_ids"]
      show.poster_path = show_data["poster_path"]
    end
  end
end
