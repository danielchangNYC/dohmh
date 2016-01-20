require 'logger'
require 'ruby-progressbar'
require 'parallel'
require 'smarter_csv'

class InspectionResultsImporter
  include Singleton

  attr_accessor :logger, :debug

  FILE_PATH = File.expand_path('./results.csv', File.dirname(__FILE__))
  LOGGER_FILE_PATH = File.expand_path('../log/import.log', File.dirname(__FILE__))

  def initialize
    @debug = false
    @logger = Logger.new(LOGGER_FILE_PATH)
  end

  def run
    opts =  { chunk_size: 1000,
              value_converters: {
                grade_date: DateConverter,
                record_date: DateConverter,
                inspection_date: DateConverter }}

    chunks = SmarterCSV.process(FILE_PATH, opts)

    Parallel.each(chunks, in_processes: 7, progress: "Recording Establishments...") do |chunk|
      record_establishments!(chunk)
    end

    Parallel.each(chunks, in_processes: 7, progress: "Recording Violations...") do |chunk|
      record_violations!(chunk)
    end

    Parallel.each(chunks, in_processes: 7, progress: "Recording Inspections...") do |chunk|
      record_inspections!(chunk)
    end

    Parallel.each(chunks, in_processes: 10, progress: "Recording Inspections...") do |chunk|
      record_inspection_violations!(chunk)
    end
  end

  def record_establishments!(chunk)
    chunk.each do |row|
      logger.debug "Recording camis #{row[:camis]}" if debug
      tries = 60

      begin
        ActiveRecord::Base.connection.reconnect!
        ActiveRecord::Base.transaction do
          establishment = Establishment.find_or_initialize_by(camis: row[:camis])
          next if establishment.persisted?
          update_establishment_from!(establishment, row)
        end
      rescue SQLite3::BusyException, ActiveRecord::StatementInvalid => e
        if tries > 0
          tries -= 1
          retry
        else
          logger.error e
        end
      end

    end
  end

  def record_violations!(chunk)
    chunk.each do |row|
      return false unless violations?(row)
      logger.debug "Recording violation #{row[:camis]}" if debug
      tries = 60

      begin
        ActiveRecord::Base.connection.reconnect!
        ActiveRecord::Base.transaction do
          violation = Violation.find_or_initialize_by(
            code: row[:violation_code].downcase,
            critical: critical_violation?(row))
          next if violation.persisted?
          violation.description = row[:violation_description].downcase if violation.description.blank?
          violation.save!
        end
      rescue SQLite3::BusyException, ActiveRecord::StatementInvalid => e
        if tries > 0
          tries -= 1
          retry
        else
          logger.error e
        end
      end

    end
  end

  def record_inspections!(chunk)
    chunk.each do |row|
      return false unless valid_inspection?(row)
      logger.debug "Recording inspection #{row[:camis]}" if debug
      tries = 60

      begin
        ActiveRecord::Base.connection.reconnect!
        establishment = Establishment.find_by!(camis: row[:camis])

        ActiveRecord::Base.transaction do
          inspection = Inspection.find_or_initialize_by(
            establishment: establishment,
            inspection_type: row[:inspection_type].downcase,
            inspection_date: row[:inspection_date])
          next if inspection.persisted?
          update_inspection_from!(inspection, row)
        end
      rescue SQLite3::BusyException, ActiveRecord::StatementInvalid => e
        if tries > 0
          tries -= 1
          retry
        else
          logger.error e
        end
      end

    end
  end

  def record_inspection_violations!(chunk)
    chunk.each do |row|
      return false unless violations?(row) || valid_inspection?(row)
      logger.info "Recording inspection violation #{row[:camis]}" if debug
      tries = 60

      begin
        ActiveRecord::Base.connection.reconnect!
        establishment = Establishment.find_by!(camis: row[:camis])
        inspection = Inspection.find_by!(
            establishment: establishment,
            inspection_type: row[:inspection_type].downcase,
            inspection_date: row[:inspection_date])
        violation = Violation.find_by!(code: row[:violation_code].downcase)

        ActiveRecord::Base.transaction do
          update_violations!(inspection, violation, row)
        end
      rescue SQLite3::BusyException, ActiveRecord::StatementInvalid => e
        if tries > 0
          tries -= 1
          retry
        else
          logger.error e
        end
      end

    end
  end

  private

  def valid?(row)
    !row[:action].blank? && !row[:dba].blank?
  end

  def valid_inspection?(row)
    !row[:inspection_type].blank?
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

  def update_violations!(inspection, violation, row)
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
