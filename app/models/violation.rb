class Violation < ActiveRecord::Base
  has_many :inspection_violations
  has_many :inspections, through: :inspection_violations

  validates :code, presence: true, uniqueness: true
  validates :critical, inclusion: { in: [true, false] }

  before_validation :sanitize_fields

  CRITICAL_FLAGS = ["Critical"]
  NON_CRITICAL_FLAGS = ["Not Critical", "Not Applicable"]

  def self.critical_flag?(flag)
    CRITICAL_FLAGS.include? flag
  end

  private

  def sanitize_fields
    self.code = code.downcase
    self.description = description.downcase if description.present?
  end
end
