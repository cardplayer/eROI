module EROI
  module Request
    class Get
      API_URL = 'http://emailer.emailroi.com/dbadmin/xml_retrieve2.pl'

      def self.api_available?
        url = URI.parse(Request::Get::API_URL)
        request = Net::HTTP::Get.new(url.path)
        response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
        response.class == Net::HTTPOK
      end

      def self.send(client, fields)
        uri = URI.parse(API_URL)
        uri.query = fields.merge({
          :user_token => client.user_token,
          :api_password => client.api_password }).collect { |k,v| "#{k}=#{v}" }.join('&')
        Response::Get.new(Crack::XML.parse(Net::HTTP.get(uri)))
      end
    end

    class Post
      API_URL = 'http://emailer.emailroi.com/dbadmin/xml_post.pl'

      def self.api_available?
        url = URI.parse(Request::Post::API_URL)
        request = Net::HTTP::Get.new(url.path)
        response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
        response.class == Net::HTTPOK
      end

      def self.send(client, xml)
        response = Net::HTTP.post_form(
           URI.parse(API_URL),
           { :user_token => client.user_token,
             :api_password => client.api_password,
             :xml_body => xml }).body
        Response::Post.new(Crack::XML.parse("<Response>#{response}</Response>"))
      end
    end
  end
end
