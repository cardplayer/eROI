$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'net/http'
require 'uri'
require 'crack'
require 'builder'
require 'activesupport'

require 'eroi/version'
require 'eroi/response'
require 'eroi/client'
