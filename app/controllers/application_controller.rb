require './config/environment'

class Dohmh < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :views, Proc.new { File.expand_path('../views', File.dirname(__FILE__)) }

  get '/' do
    erb :index
  end
end
