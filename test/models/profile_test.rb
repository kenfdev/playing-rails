# typed: false

require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "stamps profile_updated_at on save" do
    user = create(:user, :member)
    profile = user.create_profile!(name: "Alice", headline: "Engineer")

    assert_not_nil profile.profile_updated_at
    first_stamp = profile.profile_updated_at

    travel 1.minute do
      profile.update!(headline: "Senior Engineer")
    end

    assert profile.profile_updated_at > first_stamp,
           "expected profile_updated_at to advance when basic fields change"
  end

  test "saving a child work_history bumps profile_updated_at" do
    profile = create(:profile)
    initial = profile.profile_updated_at

    travel 1.minute do
      create(:work_history, profile: profile)
    end

    assert profile.reload.profile_updated_at > initial
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
