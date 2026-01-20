class Artist < ApplicationRecord
  has_many :songs, dependent: :destroy

  validates :name, :spotify_id, presence: true
  validates :spotify_id, uniqueness: true

  # Alias for compatability
  alias_attribute :title, :name
end
