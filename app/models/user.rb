# typed: false

class User < ApplicationRecord
  enum :role, { member: 0, recruiter: 1, admin: 2 }

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
