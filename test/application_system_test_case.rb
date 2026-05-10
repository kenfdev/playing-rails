# typed: false

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :playwright,
    screen_size: [ 1400, 1400 ],
    options: {
      browser_type: :chromium,
      headless: ENV["PLAYWRIGHT_HEADLESS"] != "false"
    }
end
