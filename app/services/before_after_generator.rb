class BeforeAfterGenerator

  def initialize
    @movies = Movie.all.to_a
    @tv_shows = TvShow.all.to_a
  end

  def generate_all
    puts 'Generating before and afters'

    generate_combinations(@movies, @movies, 'Movie', 'Movie')
    generate_combinations(@tv_shows, @movies, 'TvShow', 'Movie')
    generate_combinations(@movies, @tv_shows, 'Movie', 'TvShow')

    puts 'Done!'
  end

  private 

  def find_overlap(title_one, title_two)
    words_one = title_one.split
    words_two = title_two.split

    return nil if words_one.empty? || words_two.empty?

    longest_overlap = nil
    max_possible = [words_one.length, words_two.length].min

    (1..max_possible).each do |len|
      suffix = words_one[-len..]
      prefix = words_two[0, len]

      if valid_match?(suffix, prefix)
        longest_overlap = suffix.join(' ')
      end
    end

    longest_overlap
  end

  def valid_match?(suffix_words, prefix_words)
    suffix_words.each_with_index do |word_one, idx|
      word_two = prefix_words[idx]
      word_one_down = word_one.downcase
      word_two_down = word_two.downcase

      unless word_one_down == word_two_down || word_two_down.start_with?(word_one_down)
        return false
      end
    end
    true
  end

  def generate_combinations(items_one, items_two, type_one, type_two)
    items_one.each do |item_one|
      items_two.each do |item_two|
        next if item_one.id == item_two.id && type_one == type_two

        next if type_one == type_two && item_one.id > item_two.id

        overlap = find_overlap(item_one.title, item_two.title)
        next unless overlap

        create_before_after(item_one, item_two, overlap, type_one, type_two)
      end
    end
  end

  def create_before_after(item_one, item_two, connecting_word, type_one, type_two)
    full_phrase = construct_full_phrase(item_one.title, item_two.title, connecting_word)
    format = determine_format(type_one, type_two)

    BeforeAfter.find_or_create_by(
      item_one: item_one,
      item_two: item_two,
      connecting_word: connecting_word
    ) do |ba|
      ba.full_phrase = full_phrase
      ba.format = format
      ba.status = 'generated'
    end
  end

  def construct_full_phrase(title_one, title_two, connecting_word)
    words_one = title_one.split
    connecting_words = connecting_word.split

    prefix = words_one[0..-(connecting_words.length) + 1].join(' ')
    suffix = title_two

    "#{prefix} #{suffix}".strip
  end

  def determine_format(type_one, type_two)
    if(type_one == 'Movie' || type_one == 'TvShow') && (type_two == 'Movie' || type_two == 'TvShow')
      'imdb'
    else
      'imdb'
    end
  end
end
