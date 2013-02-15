require File.expand_path("#{File.dirname(__FILE__)}/test_helper")
require 'json'

module CED
  describe Email do
    ADDRESS = "john.doe@example.com"
    HOST    = "ced.example.com"
    CLIENT  = "client"
    KEY     = "A1B2c3DeFGhi"

    before do
      stub_email_verification_request(valid_email_body)
    end

    it "accepts an address" do
      email = Email.new(ADDRESS, HOST, CLIENT, KEY)
      email.instance_variable_get(:@address).must_equal(ADDRESS)
    end

    it "accepts a host" do
      email = Email.new(ADDRESS, HOST, CLIENT, KEY)
      email.instance_variable_get(:@host).must_equal(HOST)
    end

    it "accepts a client" do
      email = Email.new(ADDRESS, HOST, CLIENT, KEY)
      email.instance_variable_get(:@client).must_equal(CLIENT)
    end

    it "accepts a key" do
      email = Email.new(ADDRESS, HOST, CLIENT, KEY)
      email.instance_variable_get(:@key).must_equal(KEY)
    end

    it "requires an address" do
      lambda { Email.new(nil, HOST, CLIENT, KEY) }.must_raise(ArgumentError)
    end

    it "requires a non empty address" do
      lambda { EmailFetcher.new("", HOST, CLIENT, KEY) }.must_raise(ArgumentError)
    end

    it "requires a host" do
      ENV['CED_HOST'] = nil
      lambda { Email.new(ADDRESS, nil, CLIENT, KEY) }.must_raise(ArgumentError)
    end

    it "requires a non empty host" do
      ENV['CED_HOST'] = nil
      lambda { EmailFetcher.new(ADDRESS, "", CLIENT, KEY) }.must_raise(ArgumentError)
    end

    it "requires a client" do
      ENV['CED_CLIENT'] = nil
      lambda { Email.new(ADDRESS, HOST, nil, KEY) }.must_raise(ArgumentError)
    end

    it "requires a non empty client" do
      ENV['CED_CLIENT'] = nil
      lambda { EmailFetcher.new(ADDRESS, HOST, "", KEY) }.must_raise(ArgumentError)
    end

    it "requires a key" do
      ENV['CED_KEY'] = nil
      lambda { Email.new(ADDRESS, HOST, CLIENT, nil) }.must_raise(ArgumentError)
    end

    it "requires a non empty key" do
      ENV['CED_KEY'] = nil
      lambda { EmailFetcher.new(ADDRESS, HOST, CLIENT, "") }.must_raise(ArgumentError)
    end

    it "uses the environment variables if the host, client and key are missing" do
      ENV['CED_HOST']   = HOST
      ENV['CED_CLIENT'] = CLIENT
      ENV['CED_KEY']    = KEY
      lambda { Email.new(ADDRESS) }.must_be_silent
      ENV['CED_HOST']   = nil
      ENV['CED_CLIENT'] = nil
      ENV['CED_KEY']    = nil
    end

    describe :verified? do
      describe "when the response was successful" do
        it "returns true" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.verified?.must_equal(true)
        end
      end

      describe "when the response was not successful" do
        before do
          stub_error_email_verification_request(500)
        end

        it "returns false" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.verified?.must_equal(false)
        end
      end

      describe "when the response timed out" do
        before do
          stub_error_email_verification_request(:timeout)
        end

        it "returns false" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.verified?.must_equal(false)
        end
      end

      describe "when the response is unauthorized" do
        before do
          stub_error_email_verification_request(401)
        end

        it "returns false" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.verified?.must_equal(false)
        end
      end
    end

    describe :corrected_email do
      describe "when the response was successful" do
        it "returns the verified and corrected address from CED" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.corrected_email.must_equal("john.doe@example.com")
        end
      end

      describe "when the response was not successful" do
        before do
          stub_error_email_verification_request(500)
        end

        it "returns an empty string" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.corrected_email.must_equal("")
        end
      end
    end

    describe :valid? do
      describe "when the response was successful" do
        describe "when the address is valid" do
          it "returns true" do
            email = Email.new(ADDRESS, HOST, CLIENT, KEY)
            email.valid?.must_equal(true)
          end
        end

        describe "when the address is not valid" do
          before do
            stub_email_verification_request(invalid_email_body)
          end

          it "returns false" do
            email = Email.new(ADDRESS, HOST, CLIENT, KEY)
            email.valid?.must_equal(false)
          end
        end
      end

      describe "when the response was not successful" do
        before do
          stub_error_email_verification_request(500)
        end

        it "returns false" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.valid?.must_equal(false)
        end
      end
    end

    describe :seen_before? do
      describe "when the response was successful" do
        describe "when the address was already seen by CED" do
          it "returns true" do
            email = Email.new(ADDRESS, HOST, CLIENT, KEY)
            email.seen_before?.must_equal(true)
          end
        end

        describe "when the address was not yet seen by CED" do
          before do
            stub_email_verification_request(not_seen_before_email_body)
          end

          it "returns false" do
            email = Email.new(ADDRESS, HOST, CLIENT, KEY)
            email.seen_before?.must_equal(false)
          end
        end
      end

      describe "when the response was not successful" do
        before do
          stub_error_email_verification_request(500)
        end

        it "returns false" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.valid?.must_equal(false)
        end
      end
    end

    describe :error do
      describe "when the response was successful" do
        describe "when the address is valid" do
          it "has no error" do
            email = Email.new(ADDRESS, HOST, CLIENT, KEY)
            email.error.must_equal("")
          end
        end

        describe "when the address is not valid" do
          before do
            stub_email_verification_request(invalid_email_body)
          end

          it "has a more detailed error" do
            email = Email.new(ADDRESS, HOST, CLIENT, KEY)
            email.error.must_equal("Invalid domain name")
          end
        end
      end

      describe "when the response was not successful" do
        before do
          stub_error_email_verification_request(500)
        end

        it "returns an empty string" do
          email = Email.new(ADDRESS, HOST, CLIENT, KEY)
          email.error.must_equal("")
        end
      end
    end
  end
end
