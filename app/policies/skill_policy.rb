# frozen_string_literal: true
# typed: false

class SkillPolicy < ApplicationPolicy
  include ProfileScopedPolicy

  def create?  = own_profile?
  def destroy? = own_profile?
end
