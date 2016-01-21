ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "dohmh_#{ENV['SINATRA_ENV']}"
)

require_all 'app'
require_all 'lib'
