class IdiomImporter
  def self.import(file_path)
    puts "Importing idioms from #{file_path}"

    created_count = 0
    skipped_count = 0

    File.readlines(file_path).each_with_index do |line, index|
      line = line.strip
      next if line.empty?

      parts = line.split(":", 2)

      if parts.length != 2
        puts "skipping line #{index + 1} invalid format"
        skipped_count += 1
        next
      end

      phrase = parts[0].strip
      definition = parts[1].strip

      if Idiom.find_by(phrase: phrase)
        puts "skipping #{phrase} already exists!"
        skipped_count += 1
      else
        Idiom.create!(phrase: phrase, definition: definition)
        puts "created #{phrase} - #{definition}"
        created_count += 1
      end
    end

    puts "\nDone! Created: #{created_count}, Skipped: #{skipped_count}"
  end
end