class TmdbScraper
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

  DECADE_THRESHOLDS = {
    (1960..1969) => 2_000,
    (1970..1979) => 3_000,
    (1980..1989) => 3_000,
    (1990..1999) => 3_000,
    (2000..2009) => 5_000,
    (2010..2019) => 8_000,
    (2020..2029) => 3_000
  }.freeze

  RATE_LIMIT_TIME = 0.25

  def initialize
    @api_key = ENV['TMDB_API_KEY']
  end

  def scrape_movies
    DECADE_THRESHOLDS.each do |decade_range, vote_threshold|
      puts "Scraping #{decade_range.first}-#{decade_range.last} (vote_count >= #{vote_threshold})"

      page = 1
      loop do
        data = get_movies_page(
          page: page,
          year_min: decade_range.first,
          year_max: decade_range.last,
          vote_count_min: vote_threshold
        )

        break if data['results'].empty?

        data['results'].each do |movie_data|
          save_movie(movie_data)
        end

        puts "  Page #{page}/#{data['total_pages']} - #{data['results'].size} movies"

        break if page >= data['total_pages']
        page += 1
        sleep(RATE_LIMIT_TIME)
      end
    end
  end

  def save_movie(movie_data)
    Movie.find_or_create_by(tmdb_id: movie_data['id']) do |movie|
      movie.title = movie_data['title']
      movie.year = movie_data['release_date']&.split('-')&.first&.to_i
      movie_popularity = movie_data['popularity']
      movie.vote_count = movie_data['vote_count']
      movie.vote_average = movie_data['vote_average']
      movie.overview = movie_data['overview']
      movie.genres = movie_data['genre_ids']
      movie.poster_path = movie_data['poster_path']
    end
  end


  private 

  def get_movies_page(page:, year_min:, year_max:, vote_count_min:)
    response = self.class.get('/discover/movie', query: {
      api_key: @api_key,
      page: page,
      'primary_release_date.gte' => "#{year_min}-01-01",
      'primary_release_date.lte' => "#{year_max}-12-31",
      'vote_count.gte' => vote_count_min,
      sort_by: 'popularity.desc'
    })

    response.parsed_response
  end
end