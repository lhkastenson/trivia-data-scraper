require "csv"

class PantheonCsvParser
  TARGET_COUNT = 300

  def parse_and_save(csv_path)
    puts "Parsing Pantheon csv"

    people = []

    CSV.foreach(csv_path, headers: true) do |row|
      people << row
    end

    puts "Total people in CSV: #{people.count}"
    puts "Taking top #{TARGET_COUNT} by HPI"

    top_people = people.first(TARGET_COUNT)

    saved_count = 0

    top_people.each_with_index do |row, index|
      person = save_person(row)
      if person
        saved_count += 1
        puts "[#{index + 1}/#{TARGET_COUNT}] #{person.name} : (#{person.popularity_score})"
      end
    end

    puts "\n Saved #{saved_count} people from Pantheon dataset"
  end

  private

  def save_person(row)
    Person.find_or_create_by(
      source_type: "wikidata",
      source_id: row["wd_id"]
    ) do |person|
      person.name = row["name"]
      person.birth_year = row["birthyear"].to_i unless row["birthyear"].empty?
      person.death_year = row["deathyear"].to_i unless row["deathyear"].empty?
      person.nationality = row["byplace_country"]
      person.popularity_score = row["hpi"].to_f.round
      person.metadata = {
        occupation: row["occupation"],
        gender: row["gender"],
        alive: row["alive"] == "t",
        languages: row["l"].to_i,
        birthplace: row["bplace_name"],
        slug: row["slug"]
      }
    end
  rescue => e
    puts "  Error saving #{row["name"]}: #{e.message}"
    nil
  end
end