class InspectionViolation < ActiveRecord::Base
  belongs_to :inspection
  belongs_to :violation

  delegate :establishment, to: :inspection

  validates :inspection_id, presence: true
  validates :violation_id, presence: true
  validates :inspection_id, uniqueness: { scope: :violation_id }
end
