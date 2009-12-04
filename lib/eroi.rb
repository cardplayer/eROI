$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'net/http'
require 'uri'
require 'crack'
require 'builder'
require 'active_support'

require 'eroi/version'
require 'eroi/request'
require 'eroi/response'
require 'eroi/client'
