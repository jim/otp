# This script returns your slack username.

require "dotenv"

require_relative "./slack_credentials"
require_relative "./slack_requester"

Dotenv.load

creds = SlackCredentials.new

creds.each do |token, user_id|
  slack_requester = SlackRequester.new token, user_id
  data = slack_requester.call("auth.test")
  id = data["user_id"]

  puts "The Slack user id for token '#{token[0..8]}...' is #{id}."
end
