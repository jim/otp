# Requires a .env file that defines a Slack API test token and a user ID.
# Get a token from here: https://api.slack.com/docs/oauth-test-tokens

require "http"
require "json"

class SlackRequester
  class RequestFailure < StandardError; end

  def initialize(token, user_id)
    @user_id = user_id
    @token = token
  end

  def call(method, params = {})
    request_params = {token: @token, user: @user_id}.merge(params)
    data = make_request(method, request_params)
    if data["ok"]
      #pp data if ENV["DEBUG"]
      return data
    else
      raise RequestFailure, data["error"]
    end
  end

  def make_request(method, params)
    response = HTTP.get("https://slack.com/api/#{method}", params: params)
    JSON.parse(response.body)
  rescue HTTP::ConnectionError, JSON::ParserError => e
    raise RequestFailure, e.message
  end
end
