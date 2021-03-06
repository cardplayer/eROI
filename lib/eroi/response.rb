require 'rubygems'

module EROI
  module Response
    class Base
      attr_reader :data

      def initialize(data)
        @data = data
      end
    end

    class Get < Base
      def success?
        (@data['ErrorCode'] || @data['xml']) ? false : true
      end

      def contact
        @data['Retrieve']['Record']
      end

      alias :contacts :contact

      def error_message
        case @data['ErrorCode'].to_i
        when 1
          'Invalid username/password was provided.'
        when 2
          'Invalid mailing list was provided.'
        when 3
          'Invalid edition was provided.'
        end
      end
    end

    class Post < Base
      def success?
        @data['Response']['Compiled'] == 'Yes' &&
        @data['Response']['DBConnect'] == 'OK' &&
        @data['Response']['XMLUpload'] == 'Complete'
      end

      def number_of_records
        @data['Response']['ImportRecords'].to_i
      end
    end
  end
end
