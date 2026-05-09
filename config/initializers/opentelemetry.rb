# typed: false

require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "playing-rails")
  c.use_all
end

# Solid Queue's supervisor forks worker/dispatcher/scheduler processes. The OTLP
# HTTP exporter caches a Net::HTTP socket; if the supervisor has exported
# anything before fork, parent and child end up sharing the fd and exports
# garble. Replacing the tracer_provider wholesale doesn't help — installed
# instrumentations cache @tracer at install time and would keep routing spans
# to the old BSP. Instead, swap a fresh BSP + exporter onto the existing
# tracer_provider in each forked child so the cached tracers stay valid.
if defined?(SolidQueue)
  reinit = -> do
    provider = OpenTelemetry.tracer_provider
    next unless provider.respond_to?(:add_span_processor)

    provider.instance_variable_set(:@span_processors, [])
    provider.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        OpenTelemetry::Exporter::OTLP::Exporter.new
      )
    )
  end

  SolidQueue.on_worker_start(&reinit)
  SolidQueue.on_dispatcher_start(&reinit)
  SolidQueue.on_scheduler_start(&reinit)
end
