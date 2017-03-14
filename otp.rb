# This script updates a user's last name on Slack with the text "(otp)"
# to indicate that the user is On The Phone and may be less responsive
# as a result.

require_relative "./slack_requester"

PHONE_EMOJI = " 📞".freeze
DELAY = 60

class OTP
  def initialize
    @slack_requester = SlackRequester.new
  end

  def set_last_name(last_name)
    puts "Setting last name to #{last_name}" if ENV["DEBUG"]
    @slack_requester.call("users.profile.set", profile: { last_name: last_name }.to_json)
  end

  def run_js(name)
    output = `osascript -l JavaScript js/#{name}.js 1>&2`
    status = $?.exitstatus
    if ENV["DEBUG"]
      puts "running js #{name}: #{status}"
      puts output unless output.empty?
    end
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
    data = @slack_requester.call("users.getPresence")
    unless data["presence"] == "active"
      puts "You are not active, aborting."
      return
    end

    otp = run_js("zoom_status")
    puts "You are on a Zoom call" if otp

    unless otp
      otp = run_js("chrome_status")
      puts "You are on an appear.in call" if otp
    end

    unless otp
      otp = run_js("skype_status")
      puts "You are on a Skype call" if otp
    end

    data = @slack_requester.call("users.profile.get")
    last_name = data["profile"]["last_name"]

    otp_set = last_name.include?(PHONE_EMOJI)

    if otp_set
      puts "You are currently set to otp"
    else
      puts "You are not currently set to otp"
    end

    if otp && !otp_set
      set_last_name("#{last_name} #{PHONE_EMOJI}")
    elsif !otp && otp_set
      set_last_name(last_name.sub(PHONE_EMOJI, ""))
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
    if ENV["DEBUG"]
      puts e.message
      puts "retrying in #{delay} seconds..."
    end
    sleep delay
  end
end
