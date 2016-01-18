class Inspection < ActiveRecord::Base
  belongs_to :establishment
  has_many :inspection_violations
  has_many :violations, through: :inspection_violations

  validates :establishment_id, presence: true
  validates :action, presence: true
  validates :inspection_date, presence: true, uniqueness: { scope: :establishment_id }

  before_validation :sanitize_fields

  private

  def sanitize_fields
    self.action = action.downcase
    self.inspection_type = inspection_type.downcase if inspection_type.present?
    self.grade = grade.downcase if grade.present?
  end
end
