class SlackCredentials
  include Enumerable

  attr_accessor :credentials

  def initialize(env = ENV)
    @credentials = {}

    env.each do |key, value|
      if key =~ /TOKEN(\d*)/
        number = Regexp.last_match[1]
        user_id = env["USER_ID#{number}"]
        @credentials[value] = user_id

        if number.size == 0 # leader token is TOKEN
          @leader_token = value
        end
      end
    end
  end

  # Yields credentials in token, user_id pairs
  def each &block
    if block_given?
      @credentials.each(&block)
    else
      @credentials.each
    end
  end

  def leader
    [@leader_token, @credentials[@leader_token]]
  end

  def followers
    @credentials.reject { |k, v| k == @leader_token }
  end
end

if __FILE__ == $0
  require "minitest/autorun"

  class SlackCredentialsTest < Minitest::Test
    def test_base_extraction
      env = {"TOKEN" => "token", "USER_ID" => "user_id"}
      creds = SlackCredentials.new(env)

      expected = { "token" => "user_id" }
      assert_equal expected, creds.credentials

      assert_equal ["token", "user_id"], creds.leader
    end

    def test_multiple_extraction
      env = { "TOKEN" => "token", "USER_ID" => "user_id",
              "TOKEN2" => "token2", "USER_ID2" => "user_id2"}
      creds = SlackCredentials.new(env)

      expected = { "token" => "user_id", "token2" => "user_id2" }
      assert_equal expected, creds.credentials

      assert_equal({"token2" => "user_id2"}, creds.followers)
    end
  end
end
