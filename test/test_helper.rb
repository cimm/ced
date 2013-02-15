require 'minitest/spec'
require 'minitest/mock'
require 'minitest/autorun'
require 'webmock/minitest'
require 'ced'

FIXTURES_PATH = File.expand_path("#{File.dirname(__FILE__)}/fixtures")

def valid_email_body
  @valid_email_body ||= File.read(File.join(FIXTURES_PATH, 'valid_email.json'))
end

def invalid_email_body
  @invalid_email_body ||= File.read(File.join(FIXTURES_PATH, 'invalid_email.json'))
end

def not_seen_before_email_body
  @not_seen_before_email_body ||= File.read(File.join(FIXTURES_PATH, 'not_seen_before_email.json'))
end

def stub_email_verification_request(body)
  request  = { :headers => {'Accept' => '*/*', 'User-Agent' => 'Ruby'} }
  response = { :status => 200, :body => body, :headers => {} }
  stub_request(:get, email_verification_url).with(request).to_return(response)
end

def stub_error_email_verification_request(code)
  status           = []
  verification_url = email_verification_url
  case code
  when 401
    stub_request(:get, verification_url).to_return(:status => [401, "Unauthorized"])
  when 500
    stub_request(:get, verification_url).to_return(:status => [500, "Internal Server Error"])
  when :timeout
    stub_request(:get, verification_url).to_timeout
  else
    raise "Unknown response code: #{code}"
  end
end

def email_verification_url
  "https://ced.example.com/api/v1/Email/validate?client=client&arguments=%5B%7B%22email%22%3A%22john.doe%40example.com%22%7D%5D&signature=cfbf8f9713f81a03027b4e977f5f74af050167cb"
end
