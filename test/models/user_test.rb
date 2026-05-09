# typed: false

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires a syntactically valid email address" do
    user = build(:user, email_address: "not-an-email")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "rejects duplicate email addresses regardless of case" do
    create(:user, email_address: "dup@example.com")
    user = build(:user, email_address: "DUP@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "rejects passwords shorter than the minimum length" do
    user = build(:user, password: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end
end
