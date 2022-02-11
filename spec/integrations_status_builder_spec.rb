# frozen_string_literal: true
require 'integrations_status_builder'

RSpec.describe IntegrationsStatusBuilder do
  subject(:status_builder) do
    described_class.new(integrations, queues, workloads)
  end

  context 'with one integration without any queue', pending: true do
    let(:integrations) do
      [
        Integration.new(
          id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
        ),
      ]
    end
    let(:queues) { [] }
    let(:workloads) { [] }

    it 'shows the correct status' do
      integration_statuses = status_builder.statuses

      status1 = find_status_by_id(integration_statuses, 1)

      expect(status1).to have_attributes(
        {
          integration_id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
          workloads: 0,
          live_workloads: 0,
        },
      )
    end
  end

  context 'with two integrations without workloads', pending: true do
    let(:integrations) do
      [
        Integration.new(
          id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
        ),
        Integration.new(
          id: 2,
          tenant_id: 1,
          external_system: 'csv',
          status: 'disconnected',
        ),
      ]
    end
    let(:queues) { [Queue.new(id: 1, integration_id: 2)] }
    let(:workloads) { [] }

    it 'shows the correct status for integration 1' do
      integration_statuses = status_builder.statuses

      status1 = find_status_by_id(integration_statuses, 1)

      expect(status1).to have_attributes(
        {
          integration_id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
          workloads: 0,
          live_workloads: 0,
        },
      )
    end

    it 'shows the correct status for integration 2' do
      integration_statuses = status_builder.statuses

      status2 = find_status_by_id(integration_statuses, 2)

      expect(status2).to have_attributes(
        {
          integration_id: 2,
          tenant_id: 1,
          external_system: 'csv',
          status: 'disconnected',
          workloads: 0,
          live_workloads: 0,
        },
      )
    end
  end

  context 'with one integration having only non-live workloads',
          pending: true do
    let(:integrations) do
      [
        Integration.new(
          id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
        ),
      ]
    end
    let(:queues) do
      [Queue.new(id: 1, integration_id: 1), Queue.new(id: 2, integration_id: 1)]
    end
    let(:workloads) do
      [
        Workload.new(id: 1, history_source_queue_ids: [1, 2], mode: 'test'),
        Workload.new(id: 2, history_source_queue_ids: [2], mode: 'basic'),
      ]
    end

    it 'shows the correct status' do
      status1 = find_status_by_id(status_builder.statuses, 1)

      expect(status1).to have_attributes(
        {
          integration_id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
          workloads: 2,
          live_workloads: 0,
        },
      )
    end
  end

  context 'with one integration having live and non-live workloads',
          pending: true do
    let(:integrations) do
      [
        Integration.new(
          id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
        ),
      ]
    end
    let(:queues) do
      [
        Queue.new(id: 1, integration_id: 1),
        Queue.new(id: 2, integration_id: 1),
        Queue.new(id: 3, integration_id: 1),
      ]
    end
    let(:workloads) do
      [
        Workload.new(id: 1, history_source_queue_ids: [1, 2], mode: 'test'),
        Workload.new(id: 2, history_source_queue_ids: [2], mode: 'basic'),
        Workload.new(id: 3, history_source_queue_ids: [1, 3], mode: 'live'),
      ]
    end

    it 'shows the correct status' do
      status1 = find_status_by_id(status_builder.statuses, 1)

      expect(status1).to have_attributes(
        {
          integration_id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
          workloads: 2,
          live_workloads: 1,
        },
      )
    end
  end

  context 'with multiple integrations', pending: true do
    let(:integrations) do
      [
        Integration.new(
          id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
        ),
        Integration.new(
          id: 2,
          tenant_id: 1,
          external_system: 'csv',
          status: 'disconnected',
        ),
      ]
    end
    let(:queues) do
      [
        Queue.new(id: 1, integration_id: 1),
        Queue.new(id: 2, integration_id: 1),
        Queue.new(id: 3, integration_id: 2),
        Queue.new(id: 4, integration_id: 2),
      ]
    end
    let(:workloads) do
      [
        Workload.new(id: 1, history_source_queue_ids: [1, 2], mode: 'test'),
        Workload.new(id: 2, history_source_queue_ids: [2], mode: 'live'),
        Workload.new(id: 3, history_source_queue_ids: [1, 3], mode: 'live'),
        Workload.new(
          id: 4,
          history_source_queue_ids: [1, 2, 3, 4],
          mode: 'basic',
        ),
      ]
    end

    it 'shows the correct status for the first integration' do
      status1 = find_status_by_id(status_builder.statuses, 1)

      expect(status1).to have_attributes(
        {
          integration_id: 1,
          tenant_id: 1,
          external_system: 'freshdesk',
          status: 'connected',
          workloads: 3,
          live_workloads: 1,
        },
      )
    end

    it 'shows the correct status for the second integration' do
      status2 = find_status_by_id(status_builder.statuses, 2)

      expect(status2).to have_attributes(
        {
          integration_id: 2,
          tenant_id: 1,
          external_system: 'csv',
          status: 'disconnected',
          workloads: 2,
          live_workloads: 1,
        },
      )
    end
  end
end

def find_status_by_id(statuses, integration_id)
  statuses&.find { |status| status.integration_id == integration_id }
end
