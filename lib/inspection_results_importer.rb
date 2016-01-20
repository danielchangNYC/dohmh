require 'parallel'
require 'smarter_csv'

class InspectionResultsImporter
  include Singleton

  attr_accessor :unrecorded_rows, :errored_rows

  FILE_PATH = File.expand_path('./results.csv', File.dirname(__FILE__))

  def initialize
    @unrecorded_rows = []
    @errored_rows = []
  end

  def run
    # puts "Reading CSV. This will take a moment..."

    # CSV.read(FILE_PATH, headers: true).each do |row|
    #   if valid?(row)
    #     puts "Recording row: #{row.inspect}"
    #     record_entry!(row)
    #   else
    #     unrecorded_rows << row
    #     puts "Unrecorded row: #{row.inspect}"
    #   end
    # end

    # record_errors

    opts =  { chunk_size: 1000,
              value_converters:
              {
                grade_date: DateConverter,
                record_date: DateConverter,
                inspection_date: DateConverter
              }
            }

    chunks = SmarterCSV.process(FILE_PATH, opts)

    Parallel.map(chunks) do |chunk|
      worker(chunk)
    end
  end

  def worker(chunk)
    chunk.each do |row|
      ActiveRecord::Base.connection.reconnect!
      ActiveRecord::Base.transaction do
        if valid?(row)
          puts "Recording row: #{row[:camis]}"
          record_entry!(row)
        else
          unrecorded_rows << row
          puts "Unrecorded row: #{row[:camis]}"
        end
      end
    end
  end

  private

  def record_errors
    puts "\n =========== ERRORS: #{errored_rows.length} ============ \n"
    errored_rows.each do |row|
      puts row.inspect
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
        inspection_date: row[:inspection_date])

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
    inspection.grade_date      = row[:grade_date] if row[:grade_date]
    inspection.record_date     = row[:record_date] if row[:record_date]
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

class DateConverter
  def self.convert(value)
    Date.strptime(value, '%m/%d/%Y')
  end
end
