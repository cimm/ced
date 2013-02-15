require 'net/https'
require 'openssl'
require 'json'
require 'uri'

module CED
  class EmailFetcher
    EMAIL_PATH = "/api/v1/Email/validate"

    def initialize(host, client, key)
      raise ArgumentError, "Missing CED host"   if host.nil?   || host.strip.empty?
      raise ArgumentError, "Missing CED client" if client.nil? || client.strip.empty?
      raise ArgumentError, "Missing CED key"    if key.nil?    || key.strip.empty?
      @host   = host
      @client = client
      @key    = key
    end

    def fetch_raw_email(address)
      email_response = fetch_email(address)
      email_response.raw_email
    rescue Timeout::Error => e
      {}
    end

    def fetch_email(address)
      uri              = verification_uri(address)
      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Host certificate does not cover the subdomain
      request          = Net::HTTP::Get.new(uri.request_uri)
      response         = http.request(request)
      puts response.body
      EmailResponse.new(response)
    end

    def verification_uri(address)
      arguments = [{email: address}].to_json
      signature = sign_arguments(arguments)
      query     = URI.encode_www_form(client: @client, arguments: arguments, signature: signature)
      URI::HTTPS.build({host: @host, path: EMAIL_PATH, query: query})
    end

    private

    def sign_arguments(arguments)
      digest = OpenSSL::Digest::Digest.new("sha1")
      OpenSSL::HMAC.hexdigest(digest, @key, arguments)
    end
  end
end
