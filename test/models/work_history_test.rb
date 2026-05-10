# typed: false

require "test_helper"

class WorkHistoryTest < ActiveSupport::TestCase
  test "requires company, title, start_date" do
    entry = WorkHistory.new(profile: create(:profile))

    assert_not entry.valid?
    assert_includes entry.errors[:company],    "can't be blank"
    assert_includes entry.errors[:title],      "can't be blank"
    assert_includes entry.errors[:start_date], "can't be blank"
  end

  test "rejects end_date before start_date" do
    entry = build(:work_history,
                  start_date: Date.new(2024, 1, 1),
                  end_date:   Date.new(2023, 1, 1))

    assert_not entry.valid?
    assert_includes entry.errors[:end_date], "must be on or after start date"
  end

  test "allows nil end_date for current role" do
    entry = build(:work_history, end_date: nil)
    assert_predicate entry, :valid?
  end
end
