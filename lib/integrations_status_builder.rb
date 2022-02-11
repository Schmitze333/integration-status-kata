# frozen_string_literal: true
Integration =
  Struct.new(:id, :tenant_id, :external_system, :status, keyword_init: true)

Queue = Struct.new(:id, :integration_id, keyword_init: true)

Workload = Struct.new(:id, :history_source_queue_ids, :mode, keyword_init: true)

class IntegrationsStatusBuilder
  def initialize(integrations, queues, workloads); end

  def statuses; end
end
