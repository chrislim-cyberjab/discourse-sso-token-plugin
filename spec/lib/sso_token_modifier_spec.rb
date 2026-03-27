# frozen_string_literal: true

require "rails_helper"

describe DiscourseSSOToken::SSOTokenModifier do
  let(:sso_url) { "https://example.com/sso?sso=payload&sig=signature" }
  let(:token) { "test-token-12345" }

  before do
    SiteSetting.sso_token_enabled = true
  end

  describe "#sso_url" do
    context "when a token is present" do
      it "appends the token to the SSO URL" do
        sso = DiscourseConnect.new
        sso.token = token

        modified_url = sso.sso_url

        expect(modified_url).to include("token=#{CGI.escape(token)}")
        expect(modified_url).to start_with(sso_url)
      end

      it "handles URLs that already have query parameters" do
        sso = DiscourseConnect.new
        sso.token = token

        modified_url = sso.sso_url

        expect(modified_url).to include("&token=#{CGI.escape(token)}")
      end

      it "handles special characters in the token" do
        special_token = "token with spaces & special=chars"
        sso = DiscourseConnect.new
        sso.token = special_token

        modified_url = sso.sso_url

        expect(modified_url).to include("token=#{CGI.escape(special_token)}")
      end
    end

    context "when no token is present" do
      it "returns the original SSO URL unchanged" do
        sso = DiscourseConnect.new

        modified_url = sso.sso_url

        expect(modified_url).to eq(sso_url)
      end
    end

    context "when token is an empty string" do
      it "returns the original SSO URL unchanged" do
        sso = DiscourseConnect.new
        sso.token = ""

        modified_url = sso.sso_url

        expect(modified_url).to eq(sso_url)
      end
    end
  end
end
