require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

require_relative 'digital_ocean_ddns_client'

class IPApp < Sinatra::Base
  get '/' do
    request.ip.to_s
  end

  post '/ddns/:name' do
    name = params[:name]
    access_token = ENV['DIGITAL_OCEAN_TOKEN']
    domain_name = ENV['DOMAIN_NAME']
    ip = request.ip

    return 'Authentication failed.' unless ENV['SECRET_KEY'] == params[:secret_key]

    begin
      client = DigitalOceanDDNSClient.new(access_token, domain_name)
      changed = client.set(name, ip)

      return 'Not modified as the IP address has not changed. ' unless changed
      return "Successfully set #{name}.#{domain_name} to point to #{ip}."
    rescue DigitalOceanDDNSException => e
      return "Exception happened: #{e.message}"
    rescue => e
      return "Unexpected exception happened: #{e.message}"
    end
  end

  run! if app_file == $PROGRAM_NAME
end
