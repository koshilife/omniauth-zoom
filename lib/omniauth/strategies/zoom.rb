# frozen_string_literal: true

require 'base64'
require 'oauth2'
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # OmniAuth strategy for zoom.us
    class Zoom < OmniAuth::Strategies::OAuth2
      option :name, 'zoom'
      option :client_options, site: 'https://zoom.us'

      uid { raw_info['id'] }
      extra { {raw_info: raw_info} }

    protected

      def build_access_token
        params = {
          grant_type: 'authorization_code',
          code: request.params['code'],
          redirect_uri: callback_url
        }
        path = "#{client.options[:token_url]}?#{URI.encode_www_form(params)}"
        headers_secret = Base64.strict_encode64("#{client.id}:#{client.secret}")
        opts = {headers: {Authorization: "Basic #{headers_secret}"}}

        res = client.request(:post, path, opts)
        ::OAuth2::AccessToken.from_hash(client, res.parsed)
      end

    private

      def raw_info
        return @raw_info if defined?(@raw_info)

        @raw_info = access_token.get('/v2/users/me').parsed || {}
      rescue ::OAuth2::Error => e
        raise e unless e.response.status == 400

        # in case of missing a scope for reading current user info
        log(:error, "#{e.class} occured. message:#{e.message}")
        @raw_info = {}
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
