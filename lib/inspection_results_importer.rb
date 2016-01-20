require 'csv'

class InspectionResultsImporter
  attr_accessor :unrecorded_rows, :errored_rows

  FILE_PATH = File.expand_path('./results.csv', File.dirname(__FILE__))

  def self.run
    new.call
  end

  def initialize
    @unrecorded_rows = []
    @errored_rows = []
  end

  def call
    puts "Reading CSV. This will take a moment..."

    CSV.foreach(FILE_PATH, headers: true, header_converters: :symbol).each do |row|
      if valid?(row)
        record_entry!(row)
      else
        unrecorded_rows << row
      end
    end

    record_errors
  end

  private

  def record_errors
    File.open('../log/errors.log') do |f|
      f.write "\n =========== ERRORS: #{errored_rows.length} ============ \n"

      errored_rows.each do |row|
        f.write row.inspect
      end

      unrecorded_rows.each do |row|
        f.write row.inspect
      end
    end
  end

  def valid?(row)
    !row[:action].blank? && !row[:dba].blank?
  end

  def record_entry!(row)
    begin
      establishment = Establishment.find_or_initialize_by(camis: row[:camis])
      update_establishment_from!(establishment, row)

      inspection = Inspection.find_or_initialize_by(
        establishment: establishment,
        inspection_type: row[:inspection_type].downcase,
        inspection_date: DateTime.strptime(row[:inspection_date], "%m/%d/%Y"))

      update_inspection_from!(inspection, row)
      update_violations!(inspection, row)
    rescue StandardError => e
      errored_rows << row
    end
  end

  def update_establishment_from!(establishment, row)
    establishment.dba                 = row[:dba]
    establishment.boro                = row[:boro]
    establishment.zipcode             = row[:zipcode]
    establishment.phone               = row[:phone] if row[:phone]
    establishment.cuisine_description = row[:cuisine_description]
    establishment.save!
  end

  def update_inspection_from!(inspection, row)
    inspection.action          = row[:action].downcase if row[:action]
    inspection.score           = row[:score] if row[:score]
    inspection.grade           = row[:grade].downcase if row[:grade]
    inspection.grade_date      = DateTime.strptime(row[:grade_date], "%m/%d/%Y") if row[:grade_date]
    inspection.record_date     = DateTime.strptime(row[:record_date], "%m/%d/%Y") if row[:record_date]
    inspection.save!
  end

  def update_violations!(inspection, row)
    return false unless violations?(row)

    violation = Violation.find_or_initialize_by(
      code: row[:violation_code].downcase,
      critical: critical_violation?(row))

    violation.description = row[:violation_description].downcase if validation.description.blank?
    violation.save!

    if !InspectionViolation.exists? violation: violation, inspection: inspection
      inspection.violations << violation
      inspection.save!
    end
  end

  def violations?(row)
    row[:violation_code].present?
  end

  def critical_violation?(row)
    Violation.critical_flag? row[:critical_flag]
  end
end
