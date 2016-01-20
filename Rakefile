ENV["SINATRA_ENV"] ||= "development"

require_relative './config/environment'
require 'sinatra/activerecord/rake'

namespace :data do
  desc "Parse CSV and import to DB"
  task :import, :env do |cmd, args|
    InspectionResultsImporter.run
  end
end
