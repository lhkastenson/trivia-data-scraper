class Idiom < ApplicationRecord
  validates :phrase, presence: true, uniqueness: true

  alias_attribute :title, :phrase
end
