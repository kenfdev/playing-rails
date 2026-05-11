# typed: false

require "application_system_test_case"

class SalaryEditingTest < ApplicationSystemTestCase
  setup do
    @member = create(:user, :member)
    sign_in_as(@member)
  end

  test "a member fills in salary and sees it back on a return visit" do
    visit edit_profile_path
    click_link "Edit salary"

    fill_in "Current annual salary", with: "120000"
    fill_in "Minimum",               with: "130000"
    fill_in "Maximum",               with: "150000"
    click_button "Save salary"

    assert_text "Salary updated."

    visit edit_profile_salary_path
    assert_field "Current annual salary", with: "120000"
    assert_field "Minimum",               with: "130000"
    assert_field "Maximum",               with: "150000"
  end

  test "the public profile edit page advertises the private salary surface but shows no amounts" do
    @member.create_salary!(current_amount: 123_456, expected_min: 200_000, expected_max: 250_000)

    visit edit_profile_path

    assert_text "Salary information is kept on a separate page"
    assert_link "Edit salary"
    assert_no_text "123456"
    assert_no_text "200000"
    assert_no_text "250000"
  end
end
