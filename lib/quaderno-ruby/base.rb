module Quaderno
  require 'httparty'
  require 'json'

  class Base < OpenStruct
    include HTTParty
    include Quaderno::Exceptions
    include Quaderno::Behavior::Crud

    PRODUCTION_URL = 'https://quadernoapp.com/api/v1/'
    SANDBOX_URL = 'http://sandbox-quadernoapp.com/api/v1/'

    @@auth_token = nil
    @@rate_limit_info = nil
    @@url = PRODUCTION_URL

    # Class methods
    def self.api_model(klass)
      instance_eval <<-END
        def api_model
          #{klass}
        end
      END
      class_eval <<-END
        def api_model
          #{klass}
        end
      END
    end

    def self.configure
      yield self
    end

    def self.auth_token=(auth_token)
      @@auth_token = auth_token
    end

    def self.url=(url)
      @@url = url
    end

    def self.authorization(auth_token, mode = nil)
      begin
        mode ||= :production
        url = mode == :sandbox ? SANDBOX_URL : PRODUCTION_URL
        party_response = get("#{url}authorization.json", basic_auth: { username: auth_token })
        return  JSON::parse party_response.body
      rescue Exception
        return false
      end
    end

    #Check the connection
    def self.ping
      begin
        party_response = get("#{@@url}ping.json", basic_auth: { username: auth_token })
        check_exception_for(party_response, { subdomain_or_token: true })
      rescue Errno::ECONNREFUSED
        return false
      end
      true
    end

    #Returns the rate limit information: limit and remaining requests
    def self.rate_limit_info
      party_response = get("#{@@url}ping.json", basic_auth: { username: auth_token })
      check_exception_for(party_response, { subdomain_or_token: true })
      @@rate_limit_info = { reset: party_response.headers['x-ratelimit-reset'].to_i, remaining: party_response.headers["x-ratelimit-remaining"].to_i }
    end

    # Instance methods
    def to_hash
      self.marshal_dump
    end

    private
    def self.auth_token
      @@auth_token
    end

    def self.url
      @@url
    end

    def self.subdomain
      @_subdomain = @@subdomain
    end

    #Set or returns the model path for the url
    def self.api_path(api_path = nil)
      @_api_path ||= api_path
    end

    def self.is_a_document?(document = nil)
      @_document ||= document
    end
  end
end