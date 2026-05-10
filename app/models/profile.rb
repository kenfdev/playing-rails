# typed: false

class Profile < ApplicationRecord
  belongs_to :user
  has_many :work_histories, -> { order(start_date: :desc, id: :asc) }, dependent: :destroy
  has_many :educations,     -> { order(start_date: :desc, id: :asc) }, dependent: :destroy
  has_many :skills,         -> { order(:name) },                       dependent: :destroy

  validates :name,     length: { maximum: 120 }, allow_blank: true
  validates :headline, length: { maximum: 200 }, allow_blank: true
  validates :bio,      length: { maximum: 2000 }, allow_blank: true
end
