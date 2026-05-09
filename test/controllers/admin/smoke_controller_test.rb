# typed: false

require "test_helper"

class Admin::SmokeControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated visitors are redirected to sign in" do
    get admin_smoke_path

    assert_redirected_to new_session_path
  end

  test "admin sees the smoke page" do
    sign_in_as create(:user, :admin)

    get admin_smoke_path

    assert_response :success
    assert_select "h1", text: /smoke check/i
  end

  test "members are forbidden" do
    sign_in_as create(:user, :member)

    get admin_smoke_path

    assert_response :forbidden
  end

  test "recruiters are forbidden" do
    sign_in_as create(:user, :recruiter)

    get admin_smoke_path

    assert_response :forbidden
  end

  test "admin enqueues the smoke job" do
    sign_in_as create(:user, :admin)

    assert_enqueued_with(job: SmokeJob) do
      post admin_smoke_enqueue_path
    end

    assert_redirected_to admin_smoke_path
  end
end
