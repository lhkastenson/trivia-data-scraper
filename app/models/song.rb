class Song < ApplicationRecord
  belongs_to :artist

  validates :title, :spotify_id, presence: true
  validates :spotify_id, uniqueness: true
end
