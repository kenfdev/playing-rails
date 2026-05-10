# typed: false

require "test_helper"

class ProfileEditingFlowTest < ActionDispatch::IntegrationTest
  test "a signed-in member fills in every basic-profile field and sees them on a return visit" do
    member = create(:user, :member)
    sign_in_as(member)

    patch profile_path, params: {
      profile: { name: "Ada", headline: "Engineer", bio: "Hello." }
    }
    assert_redirected_to edit_profile_path

    post profile_work_histories_path, params: {
      work_history: { company: "Acme", title: "Engineer", start_date: "2020-01-01" }
    }
    post profile_educations_path, params: {
      education: { school: "MIT", degree: "BSc", field: "CS",
                   start_date: "2014-09-01", end_date: "2018-06-01" }
    }
    post profile_skills_path, params: { skill: { name: "Ruby" } }

    get edit_profile_path
    assert_response :success
    body = response.body

    assert_match(/Ada/, body)
    assert_match(/Engineer/, body)
    assert_match(/Hello\./, body)
    assert_match(/Acme/, body)
    assert_match(/MIT/, body)
    assert_match(/Ruby/, body)
    assert_match(/profile-last-updated/, body)
  end

  test "the basic-profile edit surface is unreachable to peer members" do
    owner = create(:user, :member)
    owner.create_profile!(name: "Owner")
    work = create(:work_history, profile: owner.profile)

    other = create(:user, :member)
    sign_in_as(other)

    patch profile_work_history_path(work), params: { work_history: { title: "Hacked" } }
    assert_response :not_found
    assert_not_equal "Hacked", work.reload.title
  end

  test "home/show shows the edit-profile link only for members" do
    member = create(:user, :member)
    sign_in_as(member)
    get root_path
    assert_match(/Edit my profile/, response.body)
    sign_out

    recruiter = create(:user, :recruiter)
    sign_in_as(recruiter)
    get root_path
    assert_no_match(/Edit my profile/, response.body)
  end
end
