class BeforeAfterGenerator
  BASE_QUALITY_SCORE = 5
  SINGLE_LOW_QUALITY_SCORE = 2
  SINGLE_MID_QUALITY_SCORE = 6
  SINGLE_HIGH_QUALITY_SCORE = 7
  MULTI_QUALITY_SCORE = 8
  WORD_COUNT_THRESH = 2
  CHAR_COUNT_LOWER_THRESH = 4
  CHAR_COUNT_UPPER_THRESH = 10

  def initialize
    @movies = Movie.all.to_a
    @tv_shows = TvShow.all.to_a
  end

  def generate_all
    puts "Generating before and afters"

    generate_combinations(@movies, @movies, "Movie", "Movie")
    generate_combinations(@tv_shows, @movies, "TvShow", "Movie")
    generate_combinations(@movies, @tv_shows, "Movie", "TvShow")

    puts "Done!"
  end

  private

  def find_overlap(title_one, title_two)
    words_one = title_one.split
    words_two = title_two.split

    return nil if words_one.empty? || words_two.empty?

    longest_overlap = nil
    max_possible = [ words_one.length, words_two.length ].min

    (1..max_possible).each do |len|
      suffix = words_one[-len..]
      prefix = words_two[0, len]

      if valid_match?(suffix, prefix)
        longest_overlap = suffix.join(" ")
      end
    end

    longest_overlap
  end

  def valid_match?(suffix_words, prefix_words)
    suffix_words.each_with_index do |word_one, idx|
      word_two = prefix_words[idx]
      word_one_down = word_one.downcase
      word_two_down = word_two.downcase

      is_last_word = (idx == suffix_words.length - 1)

      if word_one_down == word_two_down
        next
      end

      if is_last_word && word_two_down.start_with?(word_one_down)
        next
      end
      return false
    end
    true
  end

  def generate_combinations(items_one, items_two, type_one, type_two)
    items_one.each do |item_one|
      items_two.each do |item_two|
        next if item_one.id == item_two.id && type_one == type_two

        next if item_one.title.downcase == item_two.title.downcase

        if item_one.title.length != item_two.title.length
          shorter, longer = [ item_one.title.downcase, item_two.title.downcase ].sort_by(&:length)
          next if longer.include?(shorter)
        end

        overlap = find_overlap(item_one.title, item_two.title)
        next unless overlap

        create_before_after(item_one, item_two, overlap, type_one, type_two)
      end
    end
  end

  def create_before_after(item_one, item_two, connecting_word, type_one, type_two)
    full_phrase = construct_full_phrase(item_one.title, item_two.title, connecting_word)
    format = determine_format(type_one, type_two)
    quality = calculate_quality_score(connecting_word, full_phrase)

    BeforeAfter.find_or_create_by(
      item_one: item_one,
      item_two: item_two,
      connecting_word: connecting_word
    ) do |ba|
      ba.full_phrase = full_phrase
      ba.format = format
      ba.status = "generated"
      ba.quality_rating = quality
    end
  end

  def construct_full_phrase(title_one, title_two, connecting_word)
    words_one = title_one.split
    connecting_words = connecting_word.split

    words_to_keep = words_one.length - connecting_words.length

    if words_to_keep <= 0
      Rails.logger.warn "Unexpected: overlap consumed entire title - '#{title_one}' + '#{title_two}' (overlap: '#{connecting_word}')"
      puts "WARNING: Full title consumed - '#{title_one}' + '#{title_two}'"
      return title_two
    end


    prefix = words_one[0...words_to_keep].join(" ")

    "#{prefix} #{title_two}".strip
  end

  def determine_format(type_one, type_two)
    if (type_one == "Movie" || type_one == "TvShow") && (type_two == "Movie" || type_two == "TvShow")
      "imdb"
    else
      "imdb"
    end
  end

  def calculate_quality_score(connecting_word, full_phrase)
    words = connecting_word.split
    word_count = words.length
    char_count = connecting_word.length

    if word_count >= WORD_COUNT_THRESH
      return MULTI_QUALITY_SCORE
    end

    if word_count == 1
      if char_count >= CHAR_COUNT_LOWER_THRESH && char_count <= CHAR_COUNT_UPPER_THRESH
        return SINGLE_HIGH_QUALITY_SCORE
      elsif char_count > CHAR_COUNT_UPPER_THRESH
        return SINGLE_MID_QUALITY_SCORE
      else
        return SINGLE_LOW_QUALITY_SCORE
      end
    end

    BASE_QUALITY_SCORE
  end
end
