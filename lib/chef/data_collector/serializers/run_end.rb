require "securerandom"
require "chef/data_collector/serializers/base"

class Chef
  class DataCollector
    class Serializers
      class RunEnd < Base
        attr_reader :error_descriptions
        attr_reader :run_status
        attr_reader :status
        attr_reader :total_resource_count
        attr_reader :updated_resources

        def initialize(opts)
          @error_descriptions   = opts[:error_descriptions]
          @run_status           = opts[:run_status]
          @total_resource_count = opts[:total_resource_count]
          @updated_resources    = opts[:updated_resources]
          @status               = opts[:status]
        end

        def message_type
          "run_converge"
        end

        def document
          document = {
            "chef_server_fqdn"       => chef_server_fqdn,
            "entity_uuid"            => node_uuid,
            "id"                     => run_status.run_id,
            "message_version"        => "0.1.0",
            "message_type"           => message_type,
            "node_name"              => run_status.node.name,
            "organization_name"      => organization,
            "resources"              => updated_resources.map(&:for_json),
            "run_id"                 => run_status.run_id,
            "run_list"               => run_status.node.run_list.for_json,
            "start_time"             => run_status.start_time.utc.iso8601,
            "end_time"               => run_status.end_time.utc.iso8601,
            "status"                 => status,
            "total_resource_count"   => total_resource_count,
            "updated_resource_count" => updated_resources.count
          }

          document["error"] = formatted_exception if run_status.exception

          document
        end

        def formatted_exception
          {
            "class"       => run_status.exception.class,
            "message"     => run_status.exception.message,
            "backtrace"   => run_status.exception.backtrace,
            "description" => error_descriptions
          }
        end
      end
    end
  end
end
