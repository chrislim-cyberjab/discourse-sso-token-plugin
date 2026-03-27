# name: discourse-sso-token-plugin
# about: Captures token from query parameter and appends it to SSO requests
# version: 0.1
# authors: CyberJab
# url: https://github.com/cyberjab/discourse-sso-token-plugin

enabled_site_setting :sso_token_enabled

after_initialize do
  # Load the SSO token modifier
  require_relative "lib/sso_token_modifier"

  # Apply the modifier to the SSO class
  if defined?(DiscourseConnect)
    DiscourseConnect.include(DiscourseSSOToken::SSOTokenModifier)
  elsif defined?(DiscourseSSO)
    DiscourseSSO.include(DiscourseSSOToken::SSOTokenModifier)
  end

  # Register the plugin
  DiscoursePluginRegistry.serialized_current_user_fields << "sso_token"

  # Hook into the SSO process
  module ::DiscourseSSOToken
    class Engine < ::Rails::Engine
      engine_name "discourse_sso_token"
      isolate_namespace DiscourseSSOToken
    end
  end

  # Capture token from any request when present in query parameters
  ApplicationController.class_eval do
    before_action :capture_sso_token

    private

    def capture_sso_token
      if SiteSetting.sso_token_enabled
        token = params[SiteSetting.sso_token_param_name.to_sym]
        
        if token.present?
          # Store the token in the session
          session[SiteSetting.sso_token_session_key.to_sym] = token
          Rails.logger.info("[SSO Token] Token captured from URL: #{token[0..10]}...")
        end
      end
    end
  end

  # Modify the SSO provider to include the token
  on(:before_sso_provider) do |sso, request|
    if SiteSetting.sso_token_enabled
      # Get the token from the session
      token = request.session[SiteSetting.sso_token_session_key.to_sym]
      
      if token.present?
        # Store the token in the SSO object for later use
        sso.token = token
        Rails.logger.info("[SSO Token] Token retrieved from session: #{token[0..10]}...")
      end
    end
  end

  # Modify the SSO request to include the token
  on(:after_sso_provider) do |sso, request|
    if SiteSetting.sso_token_enabled && sso.token.present?
      # The token will be appended to the SSO URL in the sso_provider method
      Rails.logger.info("[SSO Token] Token will be appended to SSO request: #{sso.token[0..10]}...")
    end
  end
end
