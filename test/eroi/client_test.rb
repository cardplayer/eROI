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

    context "when adding contacts" do
      should "respond with a success" do
        response = @client.add_contacts(
          [{ :email => 'longbob@longbob.com',
             :firstname => 'Longbob',
             :lastname => 'Longson',
             :mailing_lists => 'TestList' },
           { :email => 'shortbob@shortbob.com',
             :firstname => 'Shortbob',
             :lastname => 'Shortson',
             :mainling_lists => 'TestList' }])

        assert_equal true, response.success?
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

    context "when updating contacts" do
      should "respond with a success" do
        response = @client.update_contacts(
          [{ :email => 'longbob@longbob.com',
             :firstname => 'Shortbob',
             :lastname => 'Shortson',
             :mailing_lists => 'TestList' },
           { :email => 'shortbob@shortbob.com',
             :firstname => 'Longbob',
             :lastname => 'Longson',
             :mainling_lists => 'TestList' }])

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

    context "when defining a list" do
      should "respond with a success" do
        response = @client.define_list('TestList', [ 'longbob@longbob.com' ])

        assert_equal true, response.success?
        assert_equal 1, response.number_of_records
      end
    end

    context "when sending an edition" do
      setup do
        @xml = mock('Builder::XmlMarkup')
      end

      context "when edition is meant for all contacts" do
        should "respond with a success" do
          @broadcast = 'Broadcast All'
          @xml.expects('tag!').with('Send', @broadcast, 'List' => 'TestList', 'Edition' => 'test')
          Builder::XmlMarkup.expects(:new).at_least_once.returns(@xml)

          response = @client.send_list_edition('TestList', 'test', @broadcast)

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when edition is meant for unsent contacts" do
        should "respond with a success" do
          @broadcast = 'Broadcast Unsent'
          @xml.expects('tag!').with('Send', @broadcast, 'List' => 'TestList', 'Edition' => 'test')
          Builder::XmlMarkup.expects(:new).at_least_once.returns(@xml)

          response = @client.send_list_edition('TestList', 'test', @broadcast)

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when edition is meant for random unsent contacts" do
        should "respond with a success" do
          @broadcast = 'Broadcast 200'
          @xml.expects('tag!').with('Send', @broadcast, 'List' => 'TestList', 'Edition' => 'test')
          Builder::XmlMarkup.expects(:new).at_least_once.returns(@xml)

          response = @client.send_list_edition('TestList', 'test', @broadcast)

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when edition is meant for a single contact" do
        should "respond with a success" do
          @broadcast = 'longbob@longbob.com'
          @xml.expects('tag!').with('Send', @broadcast, 'List' => 'TestList', 'Edition' => 'test')
          Builder::XmlMarkup.expects(:new).at_least_once.returns(@xml)

          response = @client.send_list_edition('TestList', 'test', @broadcast)

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when edition is meant for multiple contacts" do
        should "respond with a success" do
          @broadcast = [ 'longbob@longbob.com', 'shortbob@shortbob.com' ]
          @xml.expects('tag!').with('Send', @broadcast.join(','), 'List' => 'TestList', 'Edition' => 'test')
          Builder::XmlMarkup.expects(:new).at_least_once.returns(@xml)

          response = @client.send_list_edition('TestList', 'test', @broadcast)

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
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
        response, fields = @client.contact('longbob@longbob.com')

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
    <<-EOF
  <Retrieve>
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
  </Retrieve>
    EOF
  end
  
  def unsuccessful_get_response(code = 1)
    "<xml><error>Unable to authorize supplied username and password</error></xml>"
  end
end
