# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
require 'minitest/autorun'
require 'webmock/minitest'

require 'omniauth-zoom'
require 'omniauth'
require 'rack/test'

class StrategyTest < Minitest::Test
  include OmniAuth::Test::StrategyTestCase
  include Rack::Test::Methods

  def setup
    @logger = Logger.new STDOUT
    OmniAuth.config.logger = @logger
    @client_id = 'DUMMY_CLIENT_ID'
    @client_secret = 'DUMMY_CLIENT_SECRET'
    @scope = 'user_profile'
    @options = {scope: @scope, provider_ignores_state: true}
    @authorization_code = 'DUMMY_AUTH_CODE'
    @access_token = 'DUMMY_TOKEN'
    @refresh_token = 'DUMMY_REFRESH_TOKEN'
  end

protected

  def strategy
    [OmniAuth::Strategies::Zoom, @client_id, @client_secret, @options]
  end

  def add_mock_exchange_token
    WebMock.enable!
    url = 'https://zoom.us/oauth/token'
    secret = Base64.strict_encode64("#{@client_id}:#{@client_secret}")
    headers = {'Authorization' => "Basic #{secret}", 'Content-Type' => 'application/x-www-form-urlencoded'}
    res_headers = {'Content-Type' => 'application/json'}
    stub_request(:post, url).with(headers: headers).to_return(status: 200, body: dummy_token_response.to_json, headers: res_headers)
  end

  def dummy_token_response
    {
      access_token: @access_token,
      token_type: 'bearer',
      refresh_token: @refresh_token,
      expires_in: 3600,
      scope: 'user_profile'
    }
  end

  def add_mock_user_info
    WebMock.enable!
    url = 'https://zoom.us/v2/users/me'
    headers = {'Authorization' => "Bearer #{@access_token}"}
    res_headers = {'Content-Type' => 'application/json'}
    stub_request(:get, url).with(headers: headers).to_return(status: 200, body: dummy_user_info_response.to_json, headers: res_headers)
  end

  def add_mock_user_info_then_fail_because_of_missing_scope
    WebMock.enable!
    url = 'https://zoom.us/v2/users/me'
    response = {code: 124, message: 'Invalid access token.'}
    headers = {'Authorization' => "Bearer #{@access_token}"}
    res_headers = {'Content-Type' => 'application/json'}
    stub_request(:get, url).with(headers: headers).to_return(status: 400, body: response.to_json, headers: res_headers)
  end

  def add_mock_user_info_then_fail_because_of_unknown
    WebMock.enable!
    url = 'https://zoom.us/v2/users/me'
    response = {code: 999, message: 'Unknown Error'}
    headers = {'Authorization' => "Bearer #{@access_token}"}
    res_headers = {'Content-Type' => 'application/json'}
    stub_request(:get, url).with(headers: headers).to_return(status: 500, body: response.to_json, headers: res_headers)
  end

  def dummy_user_info_response
    {
      id: 'KdYKjnimT4KPd8FFgQt9FQ',
      first_name: 'Jane',
      last_name: 'Dev',
      email: 'jane.dev@email.com',
      type: 2,
      role_name: 'Owner',
      pmi: 1_234_567_890,
      use_pmi: false,
      vanity_url: 'https://janedevinc.zoom.us/my/janedev',
      personal_meeting_url: 'https://janedevinc.zoom.us/j/1234567890',
      timezone: 'America/Denver',
      verified: 1,
      dept: '',
      created_at: '2019-04-05T15:24:32Z',
      last_login_time: '2019-12-16T18:02:48Z',
      last_client_version: '4.6.12611.1124(mac)',
      pic_url: 'https://janedev.zoom.us/p/KdYKjnimFR5Td8KKdQt9FQ/19f6430f-ca72-4154-8998-ede6be4542c7-837',
      host_key: '533895',
      jid: 'kdykjnimt4kpd8kkdqt9fq@xmpp.zoom.us',
      group_ids: [],
      im_group_ids: ['3NXCD9VFTCOUH8LD-QciGw'],
      account_id: 'gVcjZnYYRLDbb_MfgHuaxg',
      language: 'en-US',
      phone_country: 'US',
      phone_number: '+1 1234567891',
      status: 'active'
    }
  end
end
