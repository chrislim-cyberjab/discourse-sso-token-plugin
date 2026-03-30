# frozen_string_literal: true

module DiscourseSSOToken
  module SSOTokenModifier
    extend ActiveSupport::Concern

    included do
      # Add token attribute to SSO
      attr_accessor :token
    end

    # Override the sso_url method to append the token
    def sso_url
      url = super
      # print
      puts url
      
      if token.present?
        # Append the token to the SSO URL
        separator = url.include?("?") ? "&" : "?"
        "#{url}#{separator}token=#{CGI.escape(token)}"
      else
        url
      end
    end
  end
end


