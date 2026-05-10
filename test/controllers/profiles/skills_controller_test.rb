# typed: false

require "test_helper"

class Profiles::SkillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:user, :member)
  end

  test "create adds a skill to the current member's profile" do
    sign_in_as(@member)

    assert_difference -> { Skill.count }, 1 do
      post profile_skills_path, params: { skill: { name: "Ruby" } }
    end

    assert_redirected_to edit_profile_path
    assert_equal "Ruby", @member.reload.profile.skills.first.name
  end

  test "destroy removes a skill the member owns" do
    profile = @member.create_profile!
    skill   = create(:skill, profile: profile, name: "Ruby")
    sign_in_as(@member)

    assert_difference -> { Skill.count }, -1 do
      delete profile_skill_path(skill)
    end
  end

  test "duplicate skill submission re-renders the edit page with the error" do
    profile = @member.create_profile!
    create(:skill, profile: profile, name: "Ruby")
    sign_in_as(@member)

    assert_no_difference -> { Skill.count } do
      post profile_skills_path, params: { skill: { name: "ruby" } }
    end

    assert_response :unprocessable_entity
    assert_match(/Edit profile/, response.body)
    assert_match(/Name has already been taken/, response.body)
  end

  test "recruiter cannot reach skill endpoints" do
    sign_in_as(create(:user, :recruiter))

    post profile_skills_path, params: { skill: { name: "X" } }
    assert_response :forbidden
  end
end
