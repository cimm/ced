require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

module CED
  describe EmailFetcher do
    ADDRESS = "john.doe@example.com"
    HOST    = "ced.example.com"
    CLIENT  = "client"
    KEY     = "A1B2c3DeFGhi"

    before do
      @email_verification_request = stub_email_verification_request(valid_email_body)
    end

    it "accepts a host" do
      email_fetcher = EmailFetcher.new(HOST, CLIENT, KEY)
      email_fetcher.instance_variable_get(:@host).must_equal(HOST)
    end

    it "accepts a client" do
      email_fetcher = EmailFetcher.new(HOST, CLIENT, KEY)
      email_fetcher.instance_variable_get(:@client).must_equal(CLIENT)
    end

    it "accepts a key" do
      email_fetcher = EmailFetcher.new(HOST, CLIENT, KEY)
      email_fetcher.instance_variable_get(:@key).must_equal(KEY)
    end

    it "requires a host" do
      lambda { EmailFetcher.new(nil, CLIENT, KEY) }.must_raise(ArgumentError)
    end

    it "requires a non empty host" do
      lambda { EmailFetcher.new("", CLIENT, KEY) }.must_raise(ArgumentError)
    end

    it "requires a client" do
      lambda { EmailFetcher.new(HOST, nil, KEY) }.must_raise(ArgumentError)
    end

    it "requires a non empty client" do
      lambda { EmailFetcher.new(HOST, "", KEY) }.must_raise(ArgumentError)
    end

    it "requires a key" do
      lambda { EmailFetcher.new(HOST, CLIENT, nil) }.must_raise(ArgumentError)
    end

    it "requires a non empty key" do
      lambda { EmailFetcher.new(HOST, CLIENT, "") }.must_raise(ArgumentError)
    end

    describe :fetch_raw_email do
      it "returns the raw email" do
        email_fetcher           = EmailFetcher.new(HOST, CLIENT, KEY)
        parsed_valid_email_body = JSON.parse(valid_email_body)
        email_fetcher.fetch_raw_email(ADDRESS).must_equal(parsed_valid_email_body)
      end
    end

    describe :fetch_email do
      it "verifies the email with CED" do
        email_fetcher = EmailFetcher.new(HOST, CLIENT, KEY)
        email_fetcher.fetch_email(ADDRESS)
        assert_requested(@email_verification_request)
      end

      it "returns an email response" do
        email_fetcher = EmailFetcher.new(HOST, CLIENT, KEY)
        email_fetcher.fetch_email(ADDRESS).must_be_instance_of(EmailResponse)
      end
    end

    describe :verification_uri do
      it "returns the verification URI" do
        email_fetcher = EmailFetcher.new(HOST, CLIENT, KEY)
        uri = email_fetcher.verification_uri(ADDRESS)
        uri.to_s.must_equal("https://ced.example.com/api/v1/Email/validate?client=client&arguments=%5B%7B%22email%22%3A%22john.doe%40example.com%22%7D%5D&signature=cfbf8f9713f81a03027b4e977f5f74af050167cb")
      end
    end
  end
end
