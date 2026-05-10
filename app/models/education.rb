# typed: false

class Education < ApplicationRecord
  include DateRange

  belongs_to :profile, touch: :profile_updated_at

  validates :school, presence: true, length: { maximum: 200 }
  validates :degree, length: { maximum: 200 }, allow_blank: true
  validates :field,  length: { maximum: 200 }, allow_blank: true
end
