module EROI
  def self.new(user_token, api_password)
    EROI::Client.new(user_token, api_password)
  end

  class Client
    attr_reader :user_token, :api_password

    def initialize(user_token, api_password)
      @user_token = user_token
      @api_password = api_password
    end

    def contact(email, options = {})
      Request::Get.send(self,
        { :contact => email }.merge(options))
    end

    def add_contact(fields)
      Request::Post.send(self, build_contact_record(fields))
    end

    alias :update_contact :add_contact

    def change_contact_email(current_email, new_email)
      Request::Post.send(self, build_contact_record(
        :email => current_email,
        :change_email => new_email))
    end

    def remove_contact(email)
      Request::Post.send(self, build_contact_record(
        :email => email,
        :clear_record => 1 ))
    end

    def user_field_definitions
      response = Request::Get.send(self,
        :getUserFieldDefinitions => 1,
        :SuppressContact => 1,
        :SuppressContactData => 1)

      if response.success?
        fields = {}
        response.data['Retrieve']['UserFieldDefinitions']['UserField'].each_with_index do |field,i|
          if field.is_a?(String)
            fields[field] = "User#{i + 1}"
          else
            fields[field['Field']] = "User#{i + 1}"
          end
        end

        [ response, fields ]
      else
        [ response, {} ]
      end
    end

  private

    def build_contact_record(fields)
      xml = Builder::XmlMarkup.new
      xml.tag!('Record') do |r|
        fields.each do |k,v|
          r.tag!(k.to_s.camelize, v)
        end
      end
      xml
    end
  end
end
