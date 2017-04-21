require_relative "./logging"

class SlackAccount
  include Logging

  PHONE_EMOJI = " 📞".freeze

  def initialize(requester)
    @requester = requester
    update_names
  end

  def update_otp_status(is_otp)
    update_names

    otp_set = @last_name.include?(PHONE_EMOJI)

    if otp_set
      log "#{full_name} is currently set to otp"
    else
      log  "#{full_name} is not currently set to otp"
    end

    if is_otp && !otp_set
      set_last_name("#{@last_name} #{PHONE_EMOJI}")
      log  "Setting #{full_name} to OTP."
    elsif !is_otp && otp_set
      log  "Setting #{full_name} to not OTP."
      set_last_name(@last_name.sub(PHONE_EMOJI, ""))
    end
  end

  def present
    data = @requester.call("users.getPresence")
    data["presence"] == "active"
  end

  def update_presence(is_present)
    presence = is_present ? "auto" : "away"
    log "Setting #{full_name} presence to #{presence}."
    @requester.call("users.setPresence", presence: presence)
  end

  private

  def update_names
    data = @requester.call("users.profile.get")
    @first_name = data["profile"]["first_name"]
    @last_name = data["profile"]["last_name"]
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def set_last_name(last_name)
    @requester.call("users.profile.set", profile: { last_name: last_name }.to_json)
  end
end
