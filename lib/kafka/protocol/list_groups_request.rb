module Kafka
  module Protocol
    class ListGroupsRequest
      def api_key
        16
      end

      def response_class
        ListGroupsResponse
      end

      def encode(encoder)

      end
    end
  end
end
