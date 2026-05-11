# typed: false

class Salary < ApplicationRecord
  AMOUNT_FIELDS = %w[current_amount expected_min expected_max].freeze

  belongs_to :user

  validates :current_amount, :expected_min, :expected_max,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 1_000_000_000 },
            allow_nil: true

  validate :expected_max_not_below_min

  after_save    :touch_profile_updated_at
  after_destroy :touch_profile_updated_at

  private

  def expected_max_not_below_min
    return if expected_min.blank? || expected_max.blank?
    errors.add(:expected_max, "must be greater than or equal to expected min") if expected_max < expected_min
  end

  def touch_profile_updated_at
    return if destroyed_by_association
    return unless saved_changes.keys.intersect?(AMOUNT_FIELDS) || destroyed?
    user.profile&.touch(:profile_updated_at)
  end
end
