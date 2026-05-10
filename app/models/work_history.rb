# typed: false

class WorkHistory < ApplicationRecord
  include DateRange

  belongs_to :profile, touch: :profile_updated_at

  validates :company, presence: true, length: { maximum: 200 }
  validates :title,   presence: true, length: { maximum: 200 }
  validates :start_date, presence: true
end
