require 'droplet_kit'

class DigitalOceanDDNSException < RuntimeError; end

class DigitalOceanDDNSClient

  TOKEN_REGEX = /[a-z0-9]{64}/
  DOMAIN_NAME_REGEX = /[a-z0-9A-Z]+\.[a-z0-9A-Z]+/

  def initialize(token, domain_name)
    raise DigitalOceanDDNSException("Invalid token.") unless token =~ TOKEN_REGEX
    raise DigitalOceanDDNSException("Invalid domain name.") unless domain_name =~ DOMAIN_NAME_REGEX

    @domain_name = domain_name
    @client = DropletKit::Client.new(access_token: token)
  end

  def set(name, ip)
    records = @client.domain_records.all(for_domain: @domain_name)
    matches = records.select { |r| r.name == name && r.type == 'A' }

    raise DigitalOceanDDNSException("More than 1 existing records found.") if matches.size > 1

    begin
      record = DropletKit::DomainRecord.new(
        type: 'A',
        name: name,
        data: ip
      )

      if matches.empty?
        @client.domain_records.create(record, for_domain: @domain_name)
      else
        @client.domain_records.update(record, for_domain: @domain_name,
                                              id: matches.first.id)
      end
    rescue DropletKit::Error => e
      raise DigitalOceanDDNSException.new(e.message)
    end
  end

end
