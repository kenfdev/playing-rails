# typed: false

class SmokePolicy < ApplicationPolicy
  def show?    = user&.admin?
  def enqueue? = user&.admin?
end
