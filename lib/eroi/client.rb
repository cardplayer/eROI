module EROI
  def self.new(user_token, api_password)
    EROI::Client.new(user_token, api_password)
  end

  class Client
    POST_API_URL = 'http://emailer.emailroi.com/dbadmin/xml_post.pl'
    GET_API_URL = 'http://emailer.emailroi.com/dbadmin/xml_retrieve2.pl'

    def initialize(user_token, api_password)
      @user_token = user_token
      @api_password = api_password
    end

    def add_contact(fields)
      send_post(build_contact_record(fields))
    end

    alias :update_contact :add_contact

    def change_contact_email(current_email, new_email)
      send_post(build_contact_record(
        :email => current_email, :change_email => new_email))
    end

    def remove_contact(email)
      send_post(build_contact_record( :email => email, :clear_record => 1 ))
    end

    def user_field_definitions
      response = send_get(:getUserFieldDefinitions => 1)

      if response.success?
        fields = {}
        response.data['UserFieldDefinitions']['UserField'].each_with_index do |field,i|
          fields[field] = "User#{i + 1}"
        end
        [ response, fields ]
      else
        [ response, {} ]
      end
    end

  private

    def build_contact_record(fields)
      xml = Builder::XmlMarkup.new
      xml.record do |r|
        fields.each do |k,v|
          r.tag!(k.to_s.camelize, v)
        end
      end
      xml
    end

    def send_get(fields)
      uri = URI.parse(GET_API_URL)
      uri.query = fields.merge({
        :user_token => @user_token,
        :api_password => @api_password }).collect { |k,v| "#{k}=#{v}" }.join('&')

      Response::Get.new(Crack::XML.parse(Net::HTTP.get(uri))['Retrieve'])
    end

    def send_post(xml)
      response = Net::HTTP.post_form(
         URI.parse(POST_API_URL),
         { :user_token => @user_token,
           :api_password => @api_password,
           :body => xml }).body
      Response::Post.new(Crack::XML.parse("<Response>#{response}</Response>")['Response'])
    end
  end
end
