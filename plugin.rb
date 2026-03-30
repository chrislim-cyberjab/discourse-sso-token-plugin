# name: discourse-sso-token-plugin
# about: Captures token from query parameter and appends it to SSO requests
# version: 0.1
# authors: CyberJab
# url: https://github.com/cyberjab/discourse-sso-token-plugin

enabled_site_setting :sso_token_enabled

# Engine must be defined BEFORE after_initialize so routes.rb can mount it
module ::DiscourseSSOToken
  class Engine < ::Rails::Engine
    engine_name "discourse_sso_token"
    isolate_namespace DiscourseSSOToken
  end
end

after_initialize do
  require_relative "lib/sso_token_modifier"
  require_relative "lib/sso_token_controller"
  Discourse::Application.routes.append do
    mount ::DiscourseSSOToken::Engine, at: "/sso-token"
  end

  ApplicationController.class_eval do
    before_action :capture_sso_token

    private

    def capture_sso_token
      return unless SiteSetting.sso_token_enabled
      token = params[SiteSetting.sso_token_param_name.to_sym]
      if token.present?
        session[SiteSetting.sso_token_session_key.to_sym] = token
        Rails.logger.info("[SSO Token] Captured: #{token[0..10]}...")
      end
    end
  end

  SessionController.class_eval do
    alias_method :sso_provider_original, :sso_provider

    def sso_provider(payload = nil, confirmed_2fa_during_login = false)
      sso_provider_original(payload, confirmed_2fa_during_login)

      return unless SiteSetting.sso_token_enabled
      token = session[SiteSetting.sso_token_session_key.to_sym]
      return unless token.present?

      if response.location.present?
        uri = URI.parse(response.location)
        new_query = URI.decode_www_form(uri.query || "")
        new_query << [SiteSetting.sso_token_param_name, token]
        uri.query = URI.encode_www_form(new_query)
        redirect_to uri.to_s, status: response.status
        Rails.logger.info("[SSO Token] Appended token to SSO redirect: #{uri}")
      end
    rescue URI::InvalidURIError => e
      Rails.logger.error("[SSO Token] Failed to modify SSO URL: #{e.message}")
    end
  end
end
