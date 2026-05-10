# typed: false

require "test_helper"

class EducationTest < ActiveSupport::TestCase
  test "requires school" do
    entry = Education.new(profile: create(:profile))

    assert_not entry.valid?
    assert_includes entry.errors[:school], "can't be blank"
  end

  test "rejects end_date before start_date" do
    entry = build(:education,
                  start_date: Date.new(2018, 9, 1),
                  end_date:   Date.new(2014, 6, 1))

    assert_not entry.valid?
    assert_includes entry.errors[:end_date], "must be on or after start date"
  end
end
