class BeforeAfter < ApplicationRecord
  attr_accessor :presentation_data_json

  before_validation :parse_presentation_json, if: :presentation_data_json_changed?

  belongs_to :item_one, polymorphic: true
  belongs_to :item_two, polymorphic: true

  validates :connecting_word, :full_phrase, :format, :status, presence: true
  validates :status, inclusion: { in: %w[generated reviewed approved rejected] }
  validates :format, inclusion: { in: %w[imdb tinder concert yelp] }

  private

  def presentation_data_json_changed?
    @presentation_data_json.present?
  end

  def parse_presentation_json
    self.presentation_data = JSON.parse(@presentation_data_json)
  rescue JSON::ParserError => e
    errors.add(:presentation_data_json, "Invalid JSON: #{e.message}")
  end
end
