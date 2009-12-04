require 'test/unit'
require 'rubygems'
require 'shoulda'
require 'mocha'
require 'fakeweb'

require File.join(File.dirname(__FILE__), '..', 'lib', 'eroi')

FakeWeb.allow_net_connect = false

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def stub_get(url, filename, status=nil)
  options = { :body => fixture_file(filename) }
  options.merge!({ :status => status }) unless status.nil?
  
  FakeWeb.register_uri(:get, url, options)
end

def fixture(key)
  yaml_data = YAML.load(File.read(File.join(File.dirname(__FILE__), 'fixtures.yml')))
  symbolize_keys(yaml_data)
  yaml_data[key]
end

def symbolize_keys(hash)
  return unless hash.is_a?(Hash)
  hash.symbolize_keys!
  hash.each{|k,v| symbolize_keys(v)}
end
