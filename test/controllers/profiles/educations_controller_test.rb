# typed: false

require "test_helper"

class Profiles::EducationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:user, :member)
  end

  test "create adds an education entry to the current member's profile" do
    sign_in_as(@member)

    assert_difference -> { Education.count }, 1 do
      post profile_educations_path, params: {
        education: { school: "MIT", degree: "BSc", field: "CS",
                     start_date: "2014-09-01", end_date: "2018-06-01" }
      }
    end

    assert_redirected_to edit_profile_path
  end

  test "destroy removes an entry the member owns" do
    profile = @member.create_profile!
    entry   = create(:education, profile: profile)
    sign_in_as(@member)

    assert_difference -> { Education.count }, -1 do
      delete profile_education_path(entry)
    end
  end

  test "recruiter cannot reach education endpoints" do
    sign_in_as(create(:user, :recruiter))

    post profile_educations_path, params: { education: { school: "X" } }
    assert_response :forbidden
  end
end
