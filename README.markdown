This hodgepodge of scripts will append a phone icon to the end of your Slack last name, so that it appears like "Firstname Lastname 📞" when you are on a Zoom, Skype, or appear.in call.

## Prerequisites

* You need a recent version of Ruby and Rubygems installed.
* This program requires the `osascript` executable that ships on OS X.
* `otp_start.sh` assumes you are using chruby to manage Ruby versions. It will probably need to be adjusted for other Ruby version managers.

## Setup

1. Run `bundle` within the project directory to install all Ruby dependencies.

2. Go to System Preferences > Security & Privacy > Accessibility > Privacy and add Terminal.app to the list of apps allowed to control your computer.

3. Go to [this page](https://api.slack.com/docs/oauth-test-tokens) and request a Slack testing token. The admin of your
    slack account will need to approve this request.

4. Add the token from #1 to a `.env` file like this:

    ```
    TOKEN=the-testing-token-from-slack
    ```

5. Run `bundle exec ruby get_slack_user_id.rb` and add the value that is
   printed out to `.env`:

    ```
    TOKEN=the-testing-token-from-slack
    USER_ID=ABCD1234
    ```

6. Then run `bundle exec ruby otp.rb` to start the script. You can use `DEBUG=1 bundle exec ruby otp.rb` if things aren't working and you want some debug output.
