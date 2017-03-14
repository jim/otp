# This script returns your slack username.

require_relative "./slack_requester"

slack_requester = SlackRequester.new

data = slack_requester.call("auth.test")
id = data["user_id"]

puts "Your Slack user id is #{id}."
