# typed: false

require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "visitors land on the sign-in page with a working create-account link" do
    visit new_session_path

    assert_text "Sign in"
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"

    click_link "Create account"

    assert_current_path new_registration_path
    assert_text "Create your account"
  end
end
