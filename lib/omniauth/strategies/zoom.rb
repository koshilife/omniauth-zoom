# frozen_string_literal: true

require 'base64'
require 'oauth2'
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Zoom < OmniAuth::Strategies::OAuth2
      option :name, 'zoom'
      option :client_options, site: 'https://zoom.us'

      uid { raw_info[:id] }

      extra do
        { raw_info: raw_info }
      end

      protected

      def build_access_token
        params = {
          grant_type: 'authorization_code',
          code: request.params['code'],
          redirect_uri: callback_url
        }
        path = "#{client.options[:token_url]}?#{params.to_query}"
        token = Base64.strict_encode64("#{client.id}:#{client.secret}")
        opts = { headers: { Authorization: "Basic #{token}" } }

        response = client.request(:post, path, opts)
        access_token_opts = response.parsed.merge(deep_symbolize(options.auth_token_params))
        ::OAuth2::AccessToken.from_hash(client, access_token_opts).tap do |access_token|
          if access_token.respond_to?(:response=)
            access_token.response = response
          end
        end
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        return @raw_info unless @raw_info.nil?

        res = access_token.get('/v2/users/me')
        @raw_info = JSON.parse(res.body, symbolize_names: true)
      rescue StandardError => e
        logger = OmniAuth.config.logger
        logger&.debug("#{self.class}.#{__method__} #{e.class} occured. message:#{e.message}")
        @raw_info = {}
      end
    end
  end
end
