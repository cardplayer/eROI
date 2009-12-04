module EROI
  def self.new(user_token, api_password)
    EROI::Client.new(user_token, api_password)
  end

  class Client
    attr_reader :user_token, :api_password

    def self.api_available?
      Request::Post.api_available? &&
      Request::Get.api_available?
    end

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
