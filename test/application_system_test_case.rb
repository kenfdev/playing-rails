# typed: false

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :playwright,
    screen_size: [ 1400, 1400 ],
    options: {
      browser_type: :chromium,
      headless: ENV["PLAYWRIGHT_HEADLESS"] != "false"
    }

  private

  # Skip the sign-in form by minting a Session row and injecting the signed
  # session_id cookie straight into the Playwright browser context.
  def sign_in_as(user)
    session_record = user.sessions.create!

    visit "/up"

    page.driver.with_playwright_page do |pw_page|
      pw_page.context.add_cookies([ {
        name:  "session_id",
        value: signed_cookie_value(:session_id, session_record.id),
        url:   "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}"
      } ])
    end
  end

  def signed_cookie_value(name, value)
    jar = ActionDispatch::Cookies::CookieJar.build(ActionDispatch::TestRequest.create, {})
    jar.signed[name] = value
    jar[name]
  end
end
