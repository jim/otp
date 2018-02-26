require_relative "./logging"

class SlackAccount
  include Logging

  OTP_STATUS_HASH = { "status_text" => "On the phone",
                      "status_emoji" => ":telephone_receiver:" }
  EMPTY_STATUS_HASH = { "status_text" => "",
                        "status_emoji" => "" }

  def initialize(requester)
    @requester = requester
    load_names
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def load_names
    data = @requester.call("users.profile.get")
    @first_name = data["profile"]["first_name"]
    @last_name = data["profile"]["last_name"]
  end

  def update_otp_status(is_otp)
    otp_set = current_status == OTP_STATUS_HASH

    if otp_set
      log "#{full_name} is currently set to otp"
    else
      log  "#{full_name} is not currently set to otp"
    end

    if is_otp && !otp_set
      set_otp
      log  "Setting #{full_name} to OTP."
    elsif !is_otp && otp_set
      restore_prior_status
      log  "Setting #{full_name} to not OTP."
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

  def current_status
    data = @requester.call("users.profile.get")
    { "status_emoji" => data["profile"]["status_emoji"],
      "status_text" => data["profile"]["status_text"] }
  end

  def update_prior_status_hash
    @prior_status_hash = current_status
  end

  def set_otp
    update_prior_status_hash
    @requester.call("users.profile.set", profile: OTP_STATUS_HASH.to_json)
  end

  def restore_prior_status
    profile = @prior_status_hash || EMPTY_STATUS_HASH
    @requester.call("users.profile.set", profile: profile.to_json)
  end
end
