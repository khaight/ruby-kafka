module Kafka
  module Protocol
    class DescribeGroupsRequest
      def initialize(group_ids:)
        @group_ids = group_ids
      end

      def api_key
        15
      end

      def api_version
        0
      end

      def response_class
        DescribeGroupsResponse
      end

      def encode(encoder)
        encoder.write_array(@group_ids) {|group_id| encoder.write_string(group_id) }
      end
    end
  end
end
