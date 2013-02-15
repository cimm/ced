module CED
  class Email
    def initialize(address, host = ENV['CED_HOST'], client = ENV['CED_CLIENT'], key = ENV['CED_KEY'])
      raise ArgumentError, "Missing address"    if address.nil? || address.strip.empty?
      raise ArgumentError, "Missing CED host"   if host.nil?    || host.strip.empty?
      raise ArgumentError, "Missing CED client" if client.nil?  || client.strip.empty?
      raise ArgumentError, "Missing CED key"    if key.nil?     || key.strip.empty?
      @address = address
      @host    = host
      @client  = client
      @key     = key
    end

    def verified?
      raw_email.keys.any?
    end

    def corrected_email
      raw_email["email"] || ""
    end

    def valid?
      !!raw_email["valid"]
    end

    def seen_before?
      !!raw_email["db"]
    end

    def error
      raw_email["error"] || ""
    end

    private

    def raw_email
      email_fetcher = EmailFetcher.new(@host, @client, @key)
      @raw_email ||= email_fetcher.fetch_raw_email(@address)
    end
  end
end
