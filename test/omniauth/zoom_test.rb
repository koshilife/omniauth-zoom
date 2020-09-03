# frozen_string_literal: true

require 'test_helper'

class StrategyZoomTest < StrategyTest
  def test_it_has_a_version_number
    refute_nil ::OmniAuth::Zoom::VERSION
  end

  def test_it_has_a_client_options
    args = [@client_id, @client_secret, @options]
    strat = OmniAuth::Strategies::Zoom.new(nil, *args)
    assert_equal(@client_id, strat.options[:client_id])
    assert_equal(@client_secret, strat.options[:client_secret])
    assert_equal(@scope, strat.options[:scope])
    assert_equal('https://zoom.us', strat.options[:client_options][:site])
  end

  def test_it_returns_auth_hash_in_callback_phase
    add_mock_exchange_token
    add_mock_user_info
    post '/auth/zoom/callback', code: @authorization_code, state: 'state123'

    actual_auth = auth_hash.to_hash
    assert(!actual_auth['credentials'].delete('expires_at').nil?)
    expected_auth = {
      'provider' => 'zoom',
      'uid' => dummy_user_info_response[:id],
      'info' => {'name' => nil},
      'credentials' => {'token' => @access_token, 'refresh_token' => @refresh_token, 'expires' => true},
      'extra' => {
        'raw_info' => JSON.parse(dummy_user_info_response.to_json)
      }
    }
    assert_equal(expected_auth, actual_auth)
  end

  def test_it_returns_auth_hash_in_case_of_failure_of_get_user_info_in_callbach_phase
    add_mock_exchange_token
    add_mock_user_info_then_fail_because_of_missing_scope
    post '/auth/zoom/callback', code: @authorization_code, state: 'state123'

    actual_auth = auth_hash.to_hash
    assert(!actual_auth['credentials'].delete('expires_at').nil?)
    expected_auth = {
      'provider' => 'zoom',
      'uid' => nil,
      'info' => {'name' => nil},
      'credentials' => {'token' => @access_token, 'refresh_token' => @refresh_token, 'expires' => true},
      'extra' => {'raw_info' => {}}
    }
    assert_equal(expected_auth, actual_auth)
  end

  def test_it_does_not_return_auth_hash_in_case_of_unkonwn_failure_in_callbach_phase
    add_mock_exchange_token
    add_mock_user_info_then_fail_because_of_unknown
    post '/auth/zoom/callback', code: @authorization_code, state: 'state123'
    assert_nil(auth_hash)
  end

private

  def auth_hash
    last_request.env['omniauth.auth']
  end
end
