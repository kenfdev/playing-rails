# typed: false

require "test_helper"

class SkillTest < ActiveSupport::TestCase
  test "requires name" do
    skill = Skill.new(profile: create(:profile), name: "")

    assert_not skill.valid?
    assert_includes skill.errors[:name], "can't be blank"
  end

  test "is unique per profile, case-insensitively" do
    profile = create(:profile)
    create(:skill, profile: profile, name: "Ruby")

    duplicate = build(:skill, profile: profile, name: "ruby")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end
end
