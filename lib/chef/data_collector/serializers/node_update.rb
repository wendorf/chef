require "securerandom"
require "chef/data_collector/serializers/base"

class Chef
  class DataCollector
    class Serializers
      class NodeUpdate < Base

        attr_reader :run_status

        def initialize(run_status)
          @run_status = run_status
        end

        def message_type
          "action"
        end

        def node
          run_status.node
        end

        def document
          {
            "entity_name"       => node.name,
            "entity_type"       => "node",
            "entity_uuid"       => node_uuid,
            "id"                => SecureRandom.uuid,
            "message_version"   => "0.1.1",
            "message_type"      => message_type,
            "organization_name" => organization,
            "recorded_at"       => Time.now.utc.iso8601,
            "remote_hostname"   => node["fqdn"],
            "request_id"        => "",
            "requestor_name"    => node.name,
            "requestor_type"    => "client",
            "service_hostname"  => chef_server_fqdn,
            "source"            => source,
            "task"              => "update",
            "user_agent"        => Chef::HTTP::HTTPRequest::DEFAULT_UA,
            "data"              => node
          }
        end

        def source
          solo_run? ? "chef_solo" : "chef_client"
        end
      end
    end
  end
end
