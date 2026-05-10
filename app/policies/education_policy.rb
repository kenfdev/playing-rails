# frozen_string_literal: true
# typed: false

class EducationPolicy < ApplicationPolicy
  include ProfileScopedPolicy

  def create?  = own_profile?
  def update?  = own_profile?
  def destroy? = own_profile?
end
