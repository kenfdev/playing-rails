# typed: false

class SmokeCardComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end

  attr_reader :user
end
