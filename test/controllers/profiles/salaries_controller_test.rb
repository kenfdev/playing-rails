# typed: false

require "test_helper"

class Profiles::SalariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = create(:user, :member)
  end

  test "edit requires authentication" do
    get edit_profile_salary_path
    assert_redirected_to new_session_path
  end

  test "member can reach the salary edit page even before a salary record exists" do
    sign_in_as(@member)

    get edit_profile_salary_path
    assert_response :success
    assert_match(/Salary \(private\)/, response.body)
    assert_nil @member.reload.salary
  end

  test "member can save current and expected salary fields" do
    sign_in_as(@member)

    patch profile_salary_path, params: {
      salary: { current_amount: "120000", expected_min: "130000", expected_max: "150000" }
    }

    assert_redirected_to edit_profile_salary_path
    salary = @member.reload.salary
    assert_equal 120_000, salary.current_amount
    assert_equal 130_000, salary.expected_min
    assert_equal 150_000, salary.expected_max
  end

  test "saving a salary advances the owner's profile_updated_at" do
    @member.create_profile!(name: "Ada")
    sign_in_as(@member)

    patch profile_salary_path, params: { salary: { current_amount: "100000" } }

    assert_not_nil @member.profile.reload.profile_updated_at
  end

  test "invalid salary re-renders the edit page" do
    sign_in_as(@member)

    patch profile_salary_path, params: {
      salary: { expected_min: "200000", expected_max: "100000" }
    }

    assert_response :unprocessable_entity
    assert_match(/expected min/, response.body)
  end

  test "the public profile edit page does not surface salary values" do
    sign_in_as(@member)
    @member.create_profile!(name: "Ada")
    @member.create_salary!(current_amount: 123_456, expected_min: 200_000, expected_max: 250_000)

    get edit_profile_path
    assert_response :success
    assert_no_match(/123456/, response.body)
    assert_no_match(/200000/, response.body)
    assert_no_match(/250000/, response.body)
  end

  test "the singular salary route is auto-scoped to the current user" do
    @member.create_salary!(current_amount: 99_999)
    other = create(:user, :member)
    sign_in_as(other)

    get edit_profile_salary_path
    assert_response :success
    assert_no_match(/99999/, response.body)

    patch profile_salary_path, params: { salary: { current_amount: "1" } }
    assert_redirected_to edit_profile_salary_path
    assert_equal 99_999, @member.reload.salary.current_amount
    assert_equal 1,      other.reload.salary.current_amount
  end

  test "recruiter cannot reach the salary edit page" do
    sign_in_as(create(:user, :recruiter))

    get edit_profile_salary_path
    assert_response :forbidden
  end

  test "admin cannot reach the salary edit page" do
    sign_in_as(create(:user, :admin))

    get edit_profile_salary_path
    assert_response :forbidden
  end
end
