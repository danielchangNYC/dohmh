require 'csv'

class InspectionResultsParser
  attr_accessor :unrecorded_rows

  FILE_PATH = File.expand_path('./results.csv', File.dirname(__FILE__))

  def self.parse
    new.call
  end

  def initialize
    @unrecorded_rows = []
  end

  def call
    puts "Reading CSV. This will take a moment..."

    CSV.read(FILE_PATH, headers: true, converters: :numeric).each do |row|
      if valid?(row)
        puts "Recording row: #{row.inspect}"
        record_entry!(row)
      else
        unrecorded_rows << row
        puts "Unrecorded row: #{row.inspect}"
      end
    end
  end

  private

  def valid?(row)
    !row['ACTION'].blank? && !row["DBA"].blank?
  end

  def record_entry!(row)
    establishment = Establishment.find_or_initialize_by(camis: row["CAMIS"])
    update_establishment_from!(establishment, row)

    inspection = Inspection.find_or_initialize_by(
      establishment: establishment,
      action: row["ACTION"].downcase,
      inspection_date: Datetime.parse(row["INSPECTION DATE"]))

    update_inspection_from!(inspection, row)
    update_violations!(inspection, row)
  end

  def update_establishment_from!(establishment, row)
    establishment.dba                 = row["DBA"]
    establishment.boro                = row["BORO"]
    establishment.zipcode             = row["ZIPCODE"]
    establishment.phone               = row["PHONE"] if row["PHONE"]
    establishment.cuisine_description = row["CUISINE DESCRIPTION"]
    establishment.save!
  end

  def update_inspection_from!(inspection, row)
    inspection.score           = row["SCORE"] if row["SCORE"]
    inspection.grade           = row["GRADE"].downcase if row["GRADE"]
    inspection.grade_date      = Datetime.parse(row["GRADE DATE"]) if row["GRADE DATE"]
    inspection.record_date     = Datetime.parse(row["RECORD DATE"]) if row["RECORD DATE"]
    inspection.inspection_type = row["INSPECTION TYPE"] if row["INSPECTION TYPE"]
    inspection.save!
  end

  def update_violations!(inspection, row)
    return false unless violations?(row)

    violation = Violation.find_or_create_by!(
      code: row["VIOLATION CODE"].downcase,
      description: row["VIOLATION DESCRIPTION"].downcase,
      critical: critical_violation?(row))

    if !InspectionViolation.exists? violation: violation, inspection: inspection
      inspection.violations << violation
      inspection.save!
    end
  end

  def violations?(row)
    row["VIOLATION CODE"].present?
  end

  def critical_violation?(row)
    Violation.critical_flag? row["CRITICAL FLAG"]
  end
end
