# frozen_string_literal: true
# typed: false

class SalaryPolicy < ApplicationPolicy
  def edit?   = active_member?
  def update? = active_member?

  private

  def active_member?
    user&.member? && user.active?
  end
end
