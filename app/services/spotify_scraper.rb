require "rspotify"

class SpotifyScraper
  SONG_POPULARITY_THRESHOLD = 75
  ARTIST_LIMIT = 1000
  SONGS_PER_ARTIST = 3
  SPOTIFY_RATE_LIMIT = 0.1

  def initialize
    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
  end

  def scrape_all
    puts "Starting spotify scrape"

    artists = scrape_top_artists
    puts "Found #{artists.count} artists"

    artists.each_with_index do |artist, index|
      puts "[#{index + 1}/#{artists.count}] Scraping songs for #{artist.name}"
      scrape_artist_songs(artist)
      sleep(SPOTIFY_RATE_LIMIT)
    end

    puts "Done! Artists: #{Artist.count}, Songs: #{Song.count}"
  end

  def scrape_from_playlist(playlist_id, fetch_artist_top_songs: true)
    puts "Scraping playlist #{playlist_id}"

    playlist = RSpotify::Playlist.find_by_id(playlist_id)
    puts "Playlist #{playlist.name} (#{playlist.tracks.count} tracks)"
    sleep(SPOTIFY_RATE_LIMIT)

    playlist_artists = []
    # Scrape all tracks in playlist
    playlist.tracks.each_with_index do |track, index|
      next if track.nil?

      puts "[#{index + 1}/#{playlist.tracks.count}] #{track.name}"

      track.artists.each do |spotify_artist|
        full_artist = RSpotify::Artist.find(spotify_artist.id)
        sleep(SPOTIFY_RATE_LIMIT)

        artist = save_artist(full_artist)
        if artist
          save_song(track, artist)
          if fetch_artist_top_songs
            playlist_artists << artist unless playlist_artists.include?(artist)
          end
        end
      end
    end

    puts "Phase 1 complete #{Artist.count} artists, #{Song.count} songs from playlist"
    # optional, scrape additional songs by artist
    if fetch_artist_top_songs
      puts "Optional phase 2, "
      fetch_top_songs_for_artists(playlist_artists)
    end
  end

  private

  def scrape_top_artists
    puts "Scraping top artists"

    genres = ["pop", "rock", "hip-hop", "country", "electronic", "r-n-b", "latin", "indie"]
    artists = []

    genres.each do |genre|
      puts "  Searching #{genre}"
      results = RSpotify::Artist.search(genre, limit: 50, market: "US")
      sleep(SPOTIFY_RATE_LIMIT)
      results.each do |spotify_artist|
        save_artist(spotify_artist)
        sleep(SPOTIFY_RATE_LIMIT)
      end
    end

    Artist.order(followers: :desc).limit(ARTIST_LIMIT)
  end

  def fetch_top_songs_for_artists(artists)
    artists.each_with_index do |artist, index|
      puts "[#{index + 1}/#{Artist.count}] #{artist.name}"
      scrape_artist_songs(artist)
      sleep(SPOTIFY_RATE_LIMIT)
    end
  end

  def save_artist(spotify_artist)
    Artist.find_or_create_by(spotify_id: spotify_artist.id) do |artist|
      artist.name = spotify_artist.name
      artist.popularity = spotify_artist.popularity
      artist.followers = spotify_artist.followers["total"]
      artist.genres = spotify_artist.genres
    end
  rescue => e
    puts "  Error saving artist #{spotify_artist.name}: #{e.message}"
  end

  def scrape_artist_songs(artist)
    spotify_artist = RSpotify::Artist.find(artist.spotify_id)
    sleep(SPOTIFY_RATE_LIMIT)
    top_tracks = spotify_artist.top_tracks("US")
    sleep(SPOTIFY_RATE_LIMIT)

    saved_count = 0
    top_tracks.first(SONGS_PER_ARTIST).each do |track|
      if track.popularity >= SONG_POPULARITY_THRESHOLD
        save_song(track, artist)
        saved_count += 1
      end
    end

    puts "  Saved #{saved_count} songs (threshold: #{SONG_POPULARITY_THRESHOLD})"
  rescue => e
    puts "  Error scraping songs for #{artist.name}: #{e.message}"
  end

  def save_song(track, artist)
    Song.find_or_create_by(spotify_id: track.id) do |song|
      song.title = track.name
      song.artist = artist
      song.popularity = track.popularity
      song.album_name = track.album.name
      song.release_date = track.album.release_date
    end
  rescue => e
    puts "  Error saving song #{track.name}: #{e.message}"
  end

end