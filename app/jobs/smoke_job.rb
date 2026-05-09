# typed: false

class SmokeJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    Rails.logger.info({ event: "smoke_job", user_id: user_id }.to_json)
    OpenTelemetry::Trace.current_span&.add_event("smoke_job_ran")
  end
end
