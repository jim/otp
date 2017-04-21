# This script updates a user's last name on Slack with the text "(otp)"
# to indicate that the user is On The Phone and may be less responsive
# as a result.

require "dotenv"

Dotenv.load

require_relative "./slack_account"
require_relative "./slack_credentials"
require_relative "./slack_requester"
require_relative "./logging"

require "byebug"

DELAY = 60

class OTP
  include Logging

  def initialize
    creds = SlackCredentials.new

    @leader_account = SlackAccount.new(SlackRequester.new(*creds.leader))
    @follower_accounts = creds.followers.map do |token, user_id|
      SlackAccount.new(SlackRequester.new(token, user_id))
    end
  end

  def all_accounts
    [@leader_account].concat(@follower_accounts)
  end

  def run_js(name)
    output = `osascript -l JavaScript js/#{name}.js 1>&2`
    status = $?.exitstatus

    log "running js #{name}: #{status}"
    log(output) unless output.empty?

    case status
    when 0
      false  # not active
    when 100
      true   # on a call
    else
      raise output
    end
  end

  def update_status
    present = @leader_account.present
    @follower_accounts.each { |f| f.update_presence(present) }

    unless present
      log("You are not active; not checking for OTP status.")
      @follower_accounts.each { |f| f.update_otp_status(false) }
      return
    end

    otp = run_js("zoom_status")
    log("You are on a Zoom call") if otp

    unless otp
      otp = run_js("chrome_status")
      log("You are on an appear.in call") if otp
    end

    unless otp
      otp = run_js("skype_status")
      log("You are on a Skype call") if otp
    end

    all_accounts.each do |account|
      account.update_otp_status(otp)
    end
  end
end

otp = OTP.new
failed_requests = 0

loop do
  begin
    otp.update_status
    sleep DELAY
  rescue SlackRequester::RequestFailure => e
    failed_requests += 1
    delay = 2**failed_requests

    puts e.message
    puts "retrying in #{delay} seconds..."

    sleep delay
  end
end
