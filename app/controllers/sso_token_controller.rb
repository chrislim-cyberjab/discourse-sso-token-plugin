# frozen_string_literal: true

module DiscourseSSOToken
  class SsoTokenController < ::ApplicationController
    requires_plugin "discourse-sso-token-plugin"

    # Capture the token from the query parameter and store it in the session
    def capture_token
      token = params[SiteSetting.sso_token_param_name.to_sym]
      
      if token.present?
        # Store the token in the session
        session[SiteSetting.sso_token_session_key.to_sym] = token
        
        Rails.logger.info("[SSO Token] Token captured and stored in session: #{token[0..10]}...")
        
        # Redirect to the home page or the referrer
        redirect_to params[:redirect_to] || "/"
      else
        # No token provided, just redirect
        redirect_to "/"
      end
    end
  end
end
