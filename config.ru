require 'rubygems'
require 'bundler'

Bundler.require

require './uuid-serve'
run Sinatra::Application
