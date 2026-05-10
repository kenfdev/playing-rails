# typed: false

require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "saving the parent alone does not stamp profile_updated_at" do
    user = create(:user, :member)
    profile = user.create_profile!(name: "Alice", headline: "Engineer")

    assert_nil profile.profile_updated_at, "parent-only saves should not bump profile_updated_at"

    profile.update!(headline: "Senior Engineer")
    assert_nil profile.reload.profile_updated_at
  end

  test "saving a child work_history bumps profile_updated_at" do
    profile = create(:profile)
    assert_nil profile.profile_updated_at

    create(:work_history, profile: profile)

    assert_not_nil profile.reload.profile_updated_at
  end

  test "destroying a child education bumps profile_updated_at" do
    profile = create(:profile)
    education = create(:education, profile: profile)
    initial = profile.reload.profile_updated_at

    travel 1.minute do
      education.destroy
    end

    assert profile.reload.profile_updated_at > initial
  end

  test "destroying a child skill bumps profile_updated_at" do
    profile = create(:profile)
    skill = create(:skill, profile: profile)
    initial = profile.reload.profile_updated_at

    travel 1.minute do
      skill.destroy
    end

    assert profile.reload.profile_updated_at > initial
  end
end
