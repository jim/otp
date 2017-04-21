# Requires a .env file that defines a Slack API test token and a user ID.
# Get a token from here: https://api.slack.com/docs/oauth-test-tokens

require "http"
require "json"
require "pp"

require_relative "./slack_requester"
require_relative "./logging"

class SlackRequester
  include Logging

  class RequestFailure < StandardError; end

  def initialize(token, user_id)
    raise "must provide a token" if token.nil? || token.empty?
    raise "must provide a user_id" if user_id.nil? || user_id.empty?

    @token = token
    @user_id = user_id
  end

  def call(method, params = {})
    request_params = {token: @token, user: @user_id}.merge(params)
    data = make_request(method, request_params)
    if data["ok"]
      debug(data)
      return data
    else
      raise RequestFailure, data["error"]
    end
  end

  def make_request(method, params)
    debug(method, params)
    response = HTTP.get("https://slack.com/api/#{method}", params: params)
    JSON.parse(response.body)
  rescue HTTP::ConnectionError, JSON::ParserError => e
    raise RequestFailure, e.message
  end
end
