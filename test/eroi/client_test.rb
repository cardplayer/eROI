require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class TestClient < Test::Unit::TestCase
  context "client module" do
    should "create a new eroi client" do
      client = EROI.new(user_token, api_password)
      assert_equal EROI::Client, client.class
    end
  end

  context "using the eroi client" do
    setup do
      @client = EROI.new(user_token, api_password)
      FakeWeb.register_uri(
        :post, EROI::Client::POST_API_URL,
        :body => successful_post_response)
    end

    context "when adding a contact" do
      should "respond with a success" do
        response = @client.add_contact(
          :email => 'longbob@longbob.com',
          :firstname => 'Longbob',
          :lastname => 'Longson',
          :mailing_lists => 'List1,List2')

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
          :mailing_lists => 'List1,List2')

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
      setup do
        FakeWeb.register_uri(
          :get, /#{EROI::Client::GET_API_URL}*/,
          :body => successful_get_response)
      end

      should "respond with a success" do
        response, user_fields = @client.user_field_definitions

        expected_fields = { 'State' => 'User1', 'City' => 'User2' }

        assert_equal true, response.success?
        assert_equal expected_fields, user_fields
      end
    end

    context "when there is an error" do
      setup do
        FakeWeb.register_uri(
          :get, /#{EROI::Client::GET_API_URL}*/,
          :body => unsuccessful_get_response(1))
      end

      should "respond with a failure" do
        response, fields = @client.user_field_definitions

        assert_equal false, response.success?
        assert /Invalid/ =~ response.error_message
      end
    end
  end
end
