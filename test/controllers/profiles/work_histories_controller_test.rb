# typed: false

require "test_helper"

class Profiles::WorkHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:user, :member)
  end

  test "create adds a work history entry to the current member's profile" do
    sign_in_as(@member)

    assert_difference -> { WorkHistory.count }, 1 do
      post profile_work_histories_path, params: {
        work_history: {
          company:    "Acme",
          title:      "Engineer",
          start_date: "2020-01-01",
          end_date:   "",
          description: "Built things."
        }
      }
    end

    assert_redirected_to edit_profile_path
    entry = WorkHistory.last
    assert_equal @member.reload.profile, entry.profile
  end

  test "update edits an existing entry the member owns" do
    profile = @member.create_profile!
    entry   = create(:work_history, profile: profile)
    sign_in_as(@member)

    patch profile_work_history_path(entry), params: {
      work_history: { company: entry.company, title: "Staff Engineer", start_date: entry.start_date.iso8601 }
    }

    assert_redirected_to edit_profile_path
    assert_equal "Staff Engineer", entry.reload.title
  end

  test "destroy removes an entry the member owns" do
    profile = @member.create_profile!
    entry   = create(:work_history, profile: profile)
    sign_in_as(@member)

    assert_difference -> { WorkHistory.count }, -1 do
      delete profile_work_history_path(entry)
    end

    assert_redirected_to edit_profile_path
  end

  test "another member cannot reach a peer's work history" do
    other   = create(:user, :member)
    profile = other.create_profile!
    entry   = create(:work_history, profile: profile)

    sign_in_as(@member)

    patch profile_work_history_path(entry), params: { work_history: { title: "Hacker" } }
    assert_response :not_found
    assert_not_equal "Hacker", entry.reload.title
  end

  test "create failure re-renders the edit page with field-level errors" do
    sign_in_as(@member)

    assert_no_difference -> { WorkHistory.count } do
      post profile_work_histories_path, params: {
        work_history: { company: "", title: "", start_date: "" }
      }
    end

    assert_response :unprocessable_entity
    assert_match(/Edit profile/, response.body)
    assert_match(/Company can&#39;t be blank/, response.body)
    assert_match(/Title can&#39;t be blank/, response.body)
  end

  test "update failure re-renders the edit page and leaves the row unchanged" do
    profile = @member.create_profile!
    entry   = create(:work_history, profile: profile, title: "Engineer")
    sign_in_as(@member)

    patch profile_work_history_path(entry), params: {
      work_history: { company: entry.company, title: "", start_date: entry.start_date.iso8601 }
    }

    assert_response :unprocessable_entity
    assert_match(/Title can&#39;t be blank/, response.body)
    assert_equal "Engineer", entry.reload.title
  end

  test "recruiter cannot create work histories" do
    recruiter = create(:user, :recruiter)
    sign_in_as(recruiter)

    post profile_work_histories_path, params: {
      work_history: { company: "X", title: "Y", start_date: "2020-01-01" }
    }

    assert_response :forbidden
  end
end
