# config.ru
# rackup -p 4567
require 'rubygems'
require 'bundler'
Bundler.require

require './emeraldsiren.rb'
run Sinatra::Application