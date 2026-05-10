# typed: false

class Skill < ApplicationRecord
  belongs_to :profile, touch: :profile_updated_at

  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :profile_id, case_sensitive: false }
end
