require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class TestClient < Test::Unit::TestCase
  context "using the eroi client" do
    context "against a remote server" do
      setup do
        FakeWeb.allow_net_connect = true
        credentials = fixture(:remote)
        @client = EROI.new(credentials[:user_token], credentials[:api_password])
      end

      context "when checking if the api is available" do
        should "responsd with a a success" do
          assert true, EROI::Client.api_available?
        end
      end

      context "when finding a contact" do
        should "respond with a success" do
          @client.add_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'MainList')

          response = @client.contact('longbob@longbob.com', :mailing_lists => 'MainList')

          assert_equal true, response.success?
          assert_equal 'longbob@longbob.com', response.contact['Email']
        end
      end

      context "when adding a contact" do
        teardown do
          @client.remove_contact('longbob@boblong.com')
        end

        should "respond with a success" do
          response = @client.add_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'MainList')

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when adding contacts" do
        teardown do
          @client.remove_contact('longbob@longbob.com')
          @client.remove_contact('shortbob@shortbob.com')
        end

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
          assert_equal 2, response.number_of_records
        end
      end

      context "when changing a contact's email" do
        teardown do
          @client.remove_contact('longbob@longbob.com')
          @client.remove_contact('longbob@boblong.com')
        end

        should "respond with a success" do
          @client.add_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'MainList')

          response = @client.change_contact_email(
            'longbob@longbob.com', 'longbob@boblong.com')

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when updating a contact" do
        teardown do
          @client.remove_contact('longbob@longbob.com')
        end

        should "respond with a success" do
          @client.add_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'MainList')

          response = @client.update_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'MainList')

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when updating contacts" do
        teardown do
          @client.remove_contact('longbob@longbob.com')
          @client.remove_contact('shortbob@shortbob.com')
        end

        should "respond with a success" do
          @client.add_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'MainList')

          @client.add_contact(
            :email => 'shortbob@shortbob.com',
            :firstname => 'Shortbob',
            :lastname => 'Shortson',
            :mailing_lists => 'MainList')

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
          assert_equal 2, response.number_of_records
        end
      end

      context "when removing a contact" do
        should "respond with a success" do
          response = @client.remove_contact('longbob@longbob.com')

          assert_equal true, response.success?
          assert_equal 1, response.number_of_records
        end
      end

      context "when sending an email to a contact" do
        teardown do
          @client.remove_contact('longbob@longbob.com')
        end

        should "respond with a success" do
          @client.add_contact(
            :email => 'longbob@longbob.com',
            :firstname => 'Longbob',
            :lastname => 'Longson',
            :mailing_lists => 'MainList')

          response = @client.send_list_edition('MainList', 'Testing', 'longbob@longbob.com')

          assert_equal true, response.success?
        end
      end

      context "when there is an error" do
        setup do
          @client = EROI.new('wrong', 'credentials')
        end

        should "respond with a failure" do
          response, fields = @client.contact('longbob@longbob.com')

          assert_equal false, response.success?
        end
      end
    end
  end
end
