# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Zoom < OmniAuth::Strategies::OAuth2
      option :name, 'zoom'
      option :client_options, site: 'https://zoom.us',
                              authorize_url: '/oauth/authorize',
                              token_url: '/oauth/token'

      uid { raw_info[:id] }

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        return @raw_info unless @raw_info.nil?

        res = access_token.get '/v2/users/me'
        @raw_info = JSON.parse(res.body, symbolize_names: true)
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
