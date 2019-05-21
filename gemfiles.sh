#!/bin/bash

gem uninstall bundler -v ">= 2"
gem install bundler -v '< 2'
for var in 1 2 3 4 5 6 7 8
do
  echo ">> Gemfile >> ${var}"
  bundle update rake --gemfile=gemfiles/rspec_3_${var}.gemfile
  bundle install --gemfile=gemfiles/rspec_3_${var}.gemfile
done
