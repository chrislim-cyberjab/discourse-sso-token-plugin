# frozen_string_literal: true

module DiscourseSSOToken
  class SsoTokenController < ::ApplicationController
    requires_plugin "discourse-sso-token-plugin"

    def capture_token
      return redirect_to("/") unless SiteSetting.sso_token_enabled

      token = params[SiteSetting.sso_token_param_name.to_sym]

      if token.present?
        session[SiteSetting.sso_token_session_key.to_sym] = token
        Rails.logger.info("[SSO Token] Stored in session: #{token[0..10]}...")
      end

      # After capturing, redirect straight into SSO flow
      # so token is in session when sso_provider runs
      redirect_to = params[:redirect_to].presence || "/"
      redirect_to redirect_to
    end
  end
end
