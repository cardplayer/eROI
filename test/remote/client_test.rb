require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class TestClient < Test::Unit::TestCase
  context "using the eroi client" do
    context "against a remote server" do
      setup do
        FakeWeb.allow_net_connect = true
        credentials = fixture(:remote)
        @client = EROI.new(credentials[:user_token], credentials[:api_password])
      end

      context "when finding a contact" do
        should "respond with a success" do
          @client.add_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'TestList')

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
          @client = EROI.new('wrong', 'credentials')
        end

        should "respond with a failure" do
          response, fields = @client.user_field_definitions

          assert_equal false, response.success?
        end
      end
    end
  end
end