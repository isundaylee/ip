require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

class IPApp < Sinatra::Base
  get '/' do
    "#{request.ip}"
  end

  run! if app_file == 0
end
