module Kafka
  module Protocol
    class DescribeGroupsResponse
      attr_reader :groups

      class DescribedGroup
        attr_reader :error_code, :group_id
        attr_reader :state, :protocol_type, :protocol, :members

        def initialize(error_code:, group_id:, state:, protocol_type:, protocol:, members:)
          @error_code = error_code
          @group_id = group_id
          @state = state
          @protocol_type = protocol_type
          @protocol = protocol
          @members = members
        end
      end

      class DescribedGroupMembers
        attr_reader :member_id, :client_id, :client_host, :member_meta_data, :member_assignment

        def initialize(member_id:, client_id:, client_host:, member_meta_data:, member_assignment:)
          @member_id = member_id
          @client_id = client_id
          @client_host = client_host
          @member_meta_data = member_meta_data
          @member_assignment = member_assignment
        end
      end

      def initialize(groups:)
        @groups = groups
      end

      def self.decode(decoder)
        groups = decoder.array do
          error_code = decoder.int16
          group_id = decoder.string
          state = decoder.string
          protocol_type = decoder.string
          protocol = decoder.string
          members = decoder.array do
            member_id = decoder.string
            client_id = decoder.string
            client_host = decoder.string
            member_meta_data = Decoder.from_string(decoder.bytes)
            member_assignment = Decoder.from_string(decoder.bytes)

            DescribedGroupMembers.new(
              member_id: member_id,
              client_id: client_id,
              client_host: client_host,
              member_meta_data: member_meta_data,
              member_assignment: member_assignment
            )
          end


          DescribedGroup.new(
            error_code: error_code,
            group_id: group_id,
            state: state,
            protocol_type: protocol_type,
            protocol: protocol,
            members: members
          )
        end

        new(groups: groups)
      end
    end
  end
end
