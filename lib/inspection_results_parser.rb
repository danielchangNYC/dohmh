require 'csv'

class InspectionResultsParser
  FILE_PATH = File.expand_path('./results.csv', File.dirname(__FILE__))

  def self.parse
    new.call
  end

  def call
    CSV.read(FILE_PATH, headers: true).each do |row|
      # find or create in db
    end
  end
end
