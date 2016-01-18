class Establishment < ActiveRecord::Base
  has_many :inspections

  validates :camis, presence: true, uniqueness: true
  validates :dba, presence: true
  validates :boro, presence: true
  validates :zipcode, presence: true
  validates :cuisine_description, presence: true

  before_validation :sanitize_fields

  private

  def sanitize_fields
    self.dba = dba.downcase
    self.boro = boro.downcase
    self.cuisine_description = cuisine_description.downcase
  end
end
