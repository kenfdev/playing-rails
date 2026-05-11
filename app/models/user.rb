# typed: false

class User < ApplicationRecord
  enum :role, { member: 0, recruiter: 1, admin: 2 }

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one  :profile,  dependent: :destroy
  has_one  :salary,   dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
