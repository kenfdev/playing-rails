# typed: false

Rails.application.configure do
  config.lograge.enabled = ENV["LOGRAGE_ENABLED"] != "false"
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      time: event.time,
      params: event.payload[:params]&.except("controller", "action"),
      trace_id: OpenTelemetry::Trace.current_span&.context&.hex_trace_id
    }
  end
end
