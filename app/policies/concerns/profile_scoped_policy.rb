# frozen_string_literal: true
# typed: false

module ProfileScopedPolicy
  extend ActiveSupport::Concern

  private

  def own_profile?
    return false unless user&.member? && user.active?
    record.profile&.user_id == user.id
  end
end
