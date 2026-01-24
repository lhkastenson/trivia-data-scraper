class Person < ApplicationRecord
  validates :name, :source_type, :source_id, presence: true
  validates :source_id, uniqueness: { scope: :source_type }

  # compatability with BeforeAfter generator
  alias_attribute :title, :name
end
