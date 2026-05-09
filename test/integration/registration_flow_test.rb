# typed: false

require "test_helper"

class RegistrationFlowTest < ActionDispatch::IntegrationTest
  test "a brand-new visitor can sign up, sign out, and sign back in" do
    get new_session_path
    assert_response :success

    get new_registration_path
    assert_response :success

    post registration_path, params: {
      user: {
        email_address: "flow@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_match(/flow@example.com/, response.body)

    delete session_path
    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]

    post session_path, params: {
      email_address: "flow@example.com",
      password: "password123"
    }
    assert_redirected_to root_path
    assert cookies[:session_id].present?
  end

  test "a freshly-registered member is rejected from admin-only surfaces" do
    post registration_path, params: {
      user: {
        email_address: "member-only@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to root_path

    get admin_smoke_path
    assert_response :forbidden
  end
end
