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

    CSV.read(FILE_PATH, headers: true).lazy.each do |row|
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
    !row['ACTION'].blank? && !row["DBA"].blank?
  end

  def record_entry!(row)
    begin
      establishment = Establishment.find_or_initialize_by(camis: row["CAMIS"])
      update_establishment_from!(establishment, row)

      inspection = Inspection.find_or_initialize_by(
        establishment: establishment,
        inspection_type: row["INSPECTION TYPE"].downcase,
        inspection_date: DateTime.strptime(row["INSPECTION DATE"], "%m/%d/%Y"))

      update_inspection_from!(inspection, row)
      update_violations!(inspection, row)
    rescue StandardError => e
      errored_rows << row
    end
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
    inspection.action          = row["ACTION"].downcase if row["ACTION"]
    inspection.score           = row["SCORE"] if row["SCORE"]
    inspection.grade           = row["GRADE"].downcase if row["GRADE"]
    inspection.grade_date      = DateTime.strptime(row["GRADE DATE"], "%m/%d/%Y") if row["GRADE DATE"]
    inspection.record_date     = DateTime.strptime(row["RECORD DATE"], "%m/%d/%Y") if row["RECORD DATE"]
    inspection.save!
  end

  def update_violations!(inspection, row)
    return false unless violations?(row)

    violation = Violation.find_or_initialize_by(
      code: row["VIOLATION CODE"].downcase,
      critical: critical_violation?(row))

    violation.description = row["VIOLATION DESCRIPTION"].downcase if validation.description.blank?
    violation.save!

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
