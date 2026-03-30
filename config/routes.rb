# frozen_string_literal: true

DiscourseSSOToken::Engine.routes.draw do
  get "/capture" => "sso_token#capture_token"
end

