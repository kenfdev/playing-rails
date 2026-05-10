# typed: false

class Education < ApplicationRecord
  belongs_to :profile, touch: :profile_updated_at

  validates :school, presence: true, length: { maximum: 200 }
  validates :degree, length: { maximum: 200 }, allow_blank: true
  validates :field,  length: { maximum: 200 }, allow_blank: true
  validate  :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end
end
