class Violation < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :critical, inclusion: { in: [true, false] }

  before_validation :sanitize_fields

  private

  def sanitize_fields
    self.code = code.downcase
    self.description = description.downcase if description.present?
  end
end
