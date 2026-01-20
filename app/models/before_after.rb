class BeforeAfter < ApplicationRecord
  belongs_to :item_one, polymorphic: true
  belongs_to :item_two, polymorphic: true

  validates :connecting_word, :full_phrase, :format, :status, presence: true
  validates :status, inclusion: { in: %w[generated reviewed approved rejected] }
  validates :format, inclusion: { in: %w[imdb tinder concert yelp] }
end
