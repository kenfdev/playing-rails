# typed: false

require "test_helper"

class SmokeJobTest < ActiveJob::TestCase
  test "perform logs a structured smoke event" do
    user = create(:user, :admin)

    log = StringIO.new
    original = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(log)
    begin
      SmokeJob.perform_now(user.id)
    ensure
      Rails.logger = original
    end

    assert_match(/"event":"smoke_job"/, log.string)
    assert_match(/"user_id":#{user.id}/, log.string)
  end
end
