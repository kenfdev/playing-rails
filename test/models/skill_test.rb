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

  test "stores a normalized form of the name" do
    skill = create(:skill, profile: create(:profile), name: "  Ruby on Rails  ")
    assert_equal "ruby on rails", skill.name_normalized
  end

  test "DB-level unique index blocks duplicate normalized names across races" do
    profile = create(:profile)
    create(:skill, profile: profile, name: "Ruby")

    assert_raises(ActiveRecord::RecordNotUnique) do
      Skill.insert!({ profile_id: profile.id, name: "RUBY", name_normalized: "ruby" })
    end
  end
end
