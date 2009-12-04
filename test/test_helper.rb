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

def user_token
  'test_user_token'
end

def api_password
  'test_api_password'
end

def successful_post_response
  <<-EOF
<Compiled>Yes</Compiled>
<DBConnect>OK</DBConnect>
<EditionSuccess>MailingListName_someEditionName</EditionSuccess>
<ImportRecords>1</ImportRecords>
<ExistingRecords>1526</ExistingRecords>
<FinalCompleted>1</FinalCompleted>
<Duplicates>1</Duplicates>
<InvalidLists>0</InvalidLists>
<Triggers></Triggers>
<XMLUpload>Complete</XMLUpload>
  EOF
end

def successful_get_response
  <<-EOF
<Retrieve>
  <Record>
    <rec>523</rec>
    <Email>someone@somecompany.com</Email>
    <Firstname>Joe</Firstname>
    <Lastname>Somebody</Lastname>
    <Company>Some Company</Company>
    <User1>some data here</User1>
    <User2>We'll put more data here</User2>
    <Notes>And we'll put more notes here</Notes>
    <Edition Name="SomeEdition">
      <Sent Format="YYYYMMDDhhmm">20030913143010</Sent>
      <Read>5</Read>
      <Click URL="http://www.somelink.com">3</Click>
      <Click URL="http://www.anotherlink.com/page.htm">1</Click>
      <S2F>2</S2F>
    </Edition>
    <Event id="1" ListEdition="somelist_someedition" Date="2003-Nov-11">Sent</Event>
  </Record>
  <UserFieldDefinitions>
    <UserField Field="User1" Type="Text">State</UserField>
    <UserField Field="User2" Type="Text">City</UserField>
  </UserFieldDefinitions>
 </Retrieve>
  EOF
end

def unsuccessful_get_response(code = 1)
  "<Retrieve><ErrorCode>#{code}</ErrorCode></Retrieve>"
end
