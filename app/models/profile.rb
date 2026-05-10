# typed: false

class Profile < ApplicationRecord
  belongs_to :user
  has_many :work_histories, -> { order(start_date: :desc, id: :asc) }, dependent: :destroy
  has_many :educations,     -> { order(start_date: :desc, id: :asc) }, dependent: :destroy
  has_many :skills,         -> { order(:position, :name) },            dependent: :destroy

  validates :name,     length: { maximum: 120 }, allow_blank: true
  validates :headline, length: { maximum: 200 }, allow_blank: true
  validates :bio,      length: { maximum: 2000 }, allow_blank: true

  before_save :stamp_profile_updated_at

  private

  def stamp_profile_updated_at
    self.profile_updated_at = Time.current
  end
end
