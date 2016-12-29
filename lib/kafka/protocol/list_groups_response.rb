module Kafka
  module Protocol
    class ListGroupsResponse
      attr_reader :error_code

      attr_reader :groups

      def initialize(error_code:, groups:)
        @error_code = error_code
        @groups = groups
      end

      class Group
        attr_reader :group_id, :protocol_type

        def initialize(group_id:, protocol_type:)
          @group_id = group_id
          @protocol_type = protocol_type
        end
      end

      def self.decode(decoder)
        error_code = decoder.int16
        groups = decoder.array do
          group_id = decoder.string
          protocol_type = decoder.string
          Group.new(
            group_id: group_id,
            protocol_type: protocol_type
          )
        end

        new(
          error_code: error_code,
          groups: groups
        )
      end
    end
  end
end
