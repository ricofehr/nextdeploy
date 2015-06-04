#!/bin/bash

export PATH=/usr/local/rvm/gems/ruby-2.1.0/bin:/usr/local/rvm/gems/ruby-2.1.0@global/bin:/usr/local/rvm/rubies/ruby-2.1.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/rvm/bin:/opt/ruby/bin/
export GEM_HOME=/usr/local/rvm/gems/ruby-2.1.0
export MY_RUBY_HOME=/usr/local/rvm/rubies/ruby-2.1.0
export GEM_PATH=/usr/local/rvm/gems/ruby-2.1.0:/usr/local/rvm/gems/ruby-2.1.0@global
export RUBY_VERSION=ruby-2.1.0

[[ ! -f /ror/public/javascripts/application.js ]] && cd /ror/public && ember build -d
[[ -n "$(find /ror/public/javascripts/. -type f -mmin -1 | grep -v application.js)" ]] && cd /ror/public && ember build -d