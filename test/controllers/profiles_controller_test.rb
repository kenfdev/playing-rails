# typed: false

require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:user, :member)
  end

  test "edit requires authentication" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end

  test "member can reach edit page even before profile exists" do
    sign_in_as(@member)
    get edit_profile_path
    assert_response :success
    assert_match(/Edit profile/, response.body)
  end

  test "member can save basic profile fields" do
    sign_in_as(@member)

    patch profile_path, params: {
      profile: { name: "Ada Lovelace", headline: "Computing Pioneer", bio: "Wrote the first algorithm." }
    }

    assert_redirected_to edit_profile_path
    profile = @member.reload.profile
    assert_equal "Ada Lovelace",                profile.name
    assert_equal "Computing Pioneer",           profile.headline
    assert_equal "Wrote the first algorithm.",  profile.bio
  end

  test "profile_updated_at advances only when a child entry changes" do
    sign_in_as(@member)

    patch profile_path, params: { profile: { name: "Ada" } }
    profile = @member.reload.profile
    assert_nil profile.profile_updated_at, "parent-only changes should not stamp profile_updated_at"

    post profile_work_histories_path, params: {
      work_history: { company: "Acme", title: "Engineer", start_date: "2020-01-01" }
    }
    assert_not_nil profile.reload.profile_updated_at
  end

  test "recruiter cannot reach the profile edit page" do
    recruiter = create(:user, :recruiter)
    sign_in_as(recruiter)

    get edit_profile_path
    assert_response :forbidden
  end

  test "admin cannot reach the profile edit page" do
    admin = create(:user, :admin)
    sign_in_as(admin)

    get edit_profile_path
    assert_response :forbidden
  end
end
