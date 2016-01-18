class InspectionViolation < ActiveRecord::Base
  belongs_to :inspection
  belongs_to :violation

  validates :inspection_id, presence: true
  validates :violation_id, presence: true
end
