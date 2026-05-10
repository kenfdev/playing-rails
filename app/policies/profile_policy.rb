# frozen_string_literal: true
# typed: false

class ProfilePolicy < ApplicationPolicy
  def edit?    = own_profile?
  def update?  = own_profile?

  private

  def own_profile?
    return false unless user&.member? && user.active?
    record.user_id.nil? || record.user_id == user.id
  end
end
