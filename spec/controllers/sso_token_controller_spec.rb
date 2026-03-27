# frozen_string_literal: true

require "rails_helper"

describe DiscourseSSOToken::SsoTokenController do
  let(:token) { "test-token-12345" }

  before do
    SiteSetting.sso_token_enabled = true
    SiteSetting.sso_token_param_name = "token"
    SiteSetting.sso_token_session_key = "sso_token"
  end

  describe "#capture_token" do
    context "when a token is provided" do
      it "stores the token in the session and redirects" do
        get "/sso-token/capture", params: { token: token }

        expect(response).to redirect_to("/")
        expect(session[:sso_token]).to eq(token)
      end

      it "redirects to the specified redirect_to path" do
        get "/sso-token/capture", params: { token: token, redirect_to: "/latest" }

        expect(response).to redirect_to("/latest")
        expect(session[:sso_token]).to eq(token)
      end

      it "handles custom parameter names" do
        SiteSetting.sso_token_param_name = "auth_token"

        get "/sso-token/capture", params: { auth_token: token }

        expect(response).to redirect_to("/")
        expect(session[:sso_token]).to eq(token)
      end
    end

    context "when no token is provided" do
      it "redirects to the home page without storing anything" do
        get "/sso-token/capture"

        expect(response).to redirect_to("/")
        expect(session[:sso_token]).to be_nil
      end
    end

    context "when the token is empty" do
      it "redirects to the home page without storing anything" do
        get "/sso-token/capture", params: { token: "" }

        expect(response).to redirect_to("/")
        expect(session[:sso_token]).to be_nil
      end
    end
  end
end
