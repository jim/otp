#!/bin/bash
source /usr/local/opt/chruby/share/chruby/chruby.sh && \
chruby ruby-2.3.3 && \
cd `dirname $0` && \
exec bundle exec ruby otp.rb
