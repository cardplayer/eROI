require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class TestClient < Test::Unit::TestCase
  context "client module" do
    should "create a new eroi client" do
      credentials = fixture(:test)
      client = EROI.new(credentials[:user_token], credentials[:api_password])
      assert_equal EROI::Client, client.class
    end
  end

  context "using the eroi client" do
    setup do
      credentials = fixture(:test)
      @client = EROI.new(credentials[:user_token], credentials[:api_password])
      FakeWeb.register_uri(
        :post, EROI::Request::Post::API_URL,
        :body => successful_post_response)
      FakeWeb.register_uri(
        :get, /#{EROI::Request::Get::API_URL}*/,
        :body => successful_get_response)
    end

    context "when finding a contact" do
      should "respond with a success" do
        response = @client.contact('longbob@longbob.com', :mailing_lists => 'TestList')

        assert_equal true, response.success?
        assert_equal 'longbob@longbob.com', response.contact['Email']
      end
    end

    context "when adding a contact" do
      should "respond with a success" do
        response = @client.add_contact(
          :email => 'longbob@longbob.com',
          :firstname => 'Longbob',
          :lastname => 'Longson',
          :mailing_lists => 'TestList')

        assert_equal true, response.success?
        assert_equal 1, response.number_of_records
      end
    end

    context "when changing a contact's email" do
      should "respond with a success" do
        response = @client.change_contact_email(
          'longbob@longbob.com', 'longbob@boblong.com')

        assert_equal true, response.success?
        assert_equal 1, response.number_of_records
      end
    end

    context "when updating a contact" do
      should "respond with a success" do
        response = @client.update_contact(
          :email => 'longbob@longbob.com',
          :firstname => 'Longbob',
          :lastname => 'Longson',
          :mailing_lists => 'TestList')

        assert_equal true, response.success?
        assert_equal 1, response.number_of_records
      end
    end

    context "when removing a contact" do
      should "respond with a success" do
        response = @client.remove_contact('longbob@longbob.com')

        assert_equal true, response.success?
        assert_equal 1, response.number_of_records
      end
    end

    context "when retreiving user field definitions" do
      should "respond with a success" do
        user_field_definitions = fixture(:user_field_definitions)

        response, user_fields = @client.user_field_definitions

        assert_equal true, response.success?

        user_field_definitions.each do |k,v|
          assert_equal v, user_fields[k.to_s]
        end
      end
    end

    context "when there is an error" do
      setup do
        FakeWeb.register_uri(
          :get, /#{EROI::Request::Get::API_URL}*/,
          :body => unsuccessful_get_response(1))
      end

      should "respond with a failure" do
        response, fields = @client.user_field_definitions

        assert_equal false, response.success?
      end
    end
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
    user_field_definitions = fixture(:user_field_definitions)
    fields = user_field_definitions.collect { |k,v|
      "<UserField Field='#{v}' Type='Text'>#{k.to_s}</UserField>"
    }.join("\n")

    "<Retrieve>
    <Record>
      <rec>523</rec>
      <Email>longbob@longbob.com</Email>
      <Firstname>Joe</Firstname>
      <Lastname>Somebody</Lastname>
      <Company>Some Company</Company>
      <User1>some data here</User1>
      <User2>We'll put more data here</User2>
      <Notes>And we'll put more notes here</Notes>
      <Edition Name='SomeEdition'>
        <Sent Format='YYYYMMDDhhmm'>20030913143010</Sent>
        <Read>5</Read>
        <Click URL='http://www.somelink.com'>3</Click>
        <Click URL='http://www.anotherlink.com/page.htm'>1</Click>
        <S2F>2</S2F>
      </Edition>
      <Event id='1' ListEdition='somelist_someedition' Date='2003-Nov-11'>Sent</Event>
    </Record>
    <UserFieldDefinitions>#{fields}</UserFieldDefinitions>
   </Retrieve>"
  end
  
  def unsuccessful_get_response(code = 1)
    "<xml><error>Unable to authorize supplied username and password</error></xml>"
  end
end
