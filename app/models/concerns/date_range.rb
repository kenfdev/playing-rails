# typed: false

module DateRange
  extend ActiveSupport::Concern

  included do
    validate :end_date_after_start_date
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end
end
