require "chef/data_collector/serializers/base"

class Chef
  class DataCollector
    class Serializers
      class RunStart < Base

        attr_reader :run_status

        def initialize(run_status)
          @run_status = run_status
        end

        def message_type
          "run_start"
        end

        def document
          {
            "chef_server_fqdn"  => chef_server_fqdn,
            "entity_uuid"       => node_uuid,
            "id"                => run_status.run_id,
            "message_version"   => "0.1.0",
            "message_type"      => message_type,
            "node_name"         => run_status.node.name,
            "organization_name" => organization,
            "run_id"            => run_status.run_id,
            "start_time"        => run_status.start_time.utc.iso8601
          }
        end
      end
    end
  end
end
