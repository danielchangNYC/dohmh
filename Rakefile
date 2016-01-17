ENV["SINATRA_ENV"] ||= "development"

require_relative './config/environment'
require 'sinatra/activerecord/rake'

namespace :csv do
  desc "Parse CSV"
  task :parse, :env do |cmd, args|
    InspectionResultsParser.parse
  end
end
