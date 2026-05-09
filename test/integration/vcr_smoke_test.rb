# typed: false

require "test_helper"
require "net/http"

class VcrSmokeTest < ActiveSupport::TestCase
  test "WebMock intercepts outbound HTTP requests" do
    stub_request(:get, "https://example.test/").to_return(status: 200, body: "ok")

    response = Net::HTTP.get_response(URI("https://example.test/"))

    assert_equal "200", response.code
    assert_equal "ok", response.body
    assert_requested :get, "https://example.test/"
  end

  test "VCR is configured" do
    assert VCR.configuration.cassette_library_dir.present?
    assert_kind_of VCR::Configuration, VCR.configuration
  end
end
