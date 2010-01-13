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

    def add_contacts(records)
      records = records.collect { |r| build_contact_record(r) }
      Request::Post.send(self, records)
    end

    alias :update_contacts :add_contacts

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

    def define_list(list, records)
      xml = Builder::XmlMarkup.new
      xml.tag!('DefineMailingList', 'list' => list) do |x|
        records.each do |r|
          x.tag!('Email', r.email)
        end
      end

      Request::Post.send(self, xml)
    end

    # Sends a list edition to specified broadcast.
    # 
    # Who can consist of the following:
    #   * Broadcast All - sends to all members of the list, regardless of whether they have already received this edition
    #   * Broadcast Unsent - sends to all members of the list who have not yet received this edition
    #   * Broadcast ### - sends to ### random recipients who have not yet received this edition
    #   * A comma seperated list of emails.
    def send_list_edition(list, edition, who)
      xml = Builder::XmlMarkup.new
      xml.tag!(
        'Send',
        ((who.is_a?(String)) ? [ who ] : who).join(','),
        'List' => list,
        'Edition' => edition)

      Request::Post.send(self, xml)
    end

  private

    def build_contact_record(fields)
      xml = Builder::XmlMarkup.new
      xml.tag!('Record') do |x|
        fields.each do |k,v|
          x.tag!(k.to_s.camelize, v)
        end
      end
      xml
    end
  end
end
