# frozen_string_literal: true
# typed: false

class EducationPolicy < ApplicationPolicy
  def create?  = own_profile?
  def update?  = own_profile?
  def destroy? = own_profile?

  private

  def own_profile?
    return false unless user&.member? && user.active?
    record.profile&.user_id == user.id
  end
end
