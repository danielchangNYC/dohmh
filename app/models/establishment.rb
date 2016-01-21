class Establishment < ActiveRecord::Base
  has_many :inspections
  has_many :violations, through: :inspections

  validates :camis, presence: true, uniqueness: true
  validates :dba, presence: true
  validates :boro, presence: true
  validates :building, presence: true
  validates :street, presence: true
  validates :zipcode, presence: true
  validates :cuisine_description, presence: true

  before_validation :sanitize_fields

  def self.top(cuisine_description, amount=10)
    includes(:inspections).
      where("inspections.grade NOT NULL
        AND cuisine_description like ?", "%#{cuisine_description.downcase}%").
      order("inspections.grade ASC, inspections.grade_date DESC").
      take(amount)
  end

  def display_name
    dba.split.map(&:capitalize).join(' ')
  end

  def display_address
    "#{building} #{street.split.map(&:capitalize).join(' ')}"
  end

  private

  def sanitize_fields
    self.dba = dba.downcase
    self.boro = boro.downcase
    self.cuisine_description = cuisine_description.downcase
  end
end
