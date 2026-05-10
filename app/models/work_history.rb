# typed: false

class WorkHistory < ApplicationRecord
  belongs_to :profile, touch: :profile_updated_at

  validates :company, presence: true, length: { maximum: 200 }
  validates :title,   presence: true, length: { maximum: 200 }
  validates :start_date, presence: true
  validate  :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end
end
