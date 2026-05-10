# typed: false

class Skill < ApplicationRecord
  belongs_to :profile, touch: :profile_updated_at

  before_validation :normalize_name

  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :profile_id, case_sensitive: false }

  private

  def normalize_name
    self.name_normalized = name.to_s.strip.downcase
  end
end
