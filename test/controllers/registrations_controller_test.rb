# typed: false

require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new is publicly reachable" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid params provisions a member account and signs the user in" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: {
        user: {
          email_address: "newmember@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.find_by(email_address: "newmember@example.com")
    assert user.member?, "expected newly-registered user to have the member role"
    assert_redirected_to root_path
    assert cookies[:session_id].present?
  end

  test "create with mismatched password confirmation re-renders the form" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          email_address: "mismatch@example.com",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id].presence
  end

  test "create rejects an already-taken email address" do
    create(:user, email_address: "taken@example.com")

    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          email_address: "taken@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create ignores a role parameter and forces member" do
    post registration_path, params: {
      user: {
        email_address: "tryadmin@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "admin"
      }
    }

    user = User.find_by(email_address: "tryadmin@example.com")
    assert_not_nil user
    assert user.member?, "registration must always create a member-role account"
  end
end
