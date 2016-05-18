#
# Author:: Adam Leff (<adamleff@chef.io)
# Author:: Ryan Cragun (<ryan@chef.io>)
#
# Copyright:: Copyright 2012-2016, Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path("../../spec_helper", __FILE__)
require "chef/data_collector"

describe Chef::DataCollector::Reporter do
  let(:report) { described_class.new }

  describe '#run_started' do
    before do
      allow(report).to receive(:update_run_status)
      allow(report).to receive(:send_to_data_collector)
    end

    it "updates the run status" do
      expect(report).to receive(:update_run_status).with("test_run_status")
      report.run_started("test_run_status")
    end

    it "sends the RunStart serializer output to the Data Collector server" do
      expect(Chef::DataCollector::Serializers::RunStart).to receive(:new).and_return("run_start_data")
      expect(report).to receive(:send_to_data_collector).with("run_start_data")
      report.run_started("test_run_status")
    end
  end

  describe '#run_completed' do
    it 'sends the run completion' do
      expect(report).to receive(:send_run_completion)
      report.run_completed("fake_node")
    end
  end

  describe '#run_failed' do
    it "updates the exception and sends the run completion" do
      expect(report).to receive(:update_exception).with("test_exception")
      expect(report).to receive(:send_run_completion)
      report.run_failed("test_exception")
    end
  end

  describe '#resource_current_state_loaded' do
    let(:new_resource)     { double("new_resource") }
    let(:action)           { double("action") }
    let(:current_resource) { double("current_resource") }

    context "when resource is a nested resource" do
      it "does not update the resource report" do
        allow(report).to receive(:nested_resource?).and_return(true)
        expect(report).not_to receive(:update_current_resource_report)
        report.resource_current_state_loaded(new_resource, action, current_resource)
      end
    end

    context "when resource is not a nested resource" do
      it "updates the resource report" do
        allow(report).to receive(:nested_resource?).and_return(false)
        expect(Chef::DataCollector::ResourceReport).to receive(:for_current_resource).with(
          new_resource,
          action,
          current_resource)
        .and_return("resource_report")
        expect(report).to receive(:update_current_resource_report).with("resource_report")
        report.resource_current_state_loaded(new_resource, action, current_resource)
      end
    end
  end

  describe '#resource_up_to_date' do
    let(:new_resource) { double("new_resource") }
    let(:action)       { double("action") }

    before do
      allow(report).to receive(:increment_resource_count)
      allow(report).to receive(:nested_resource?)
      allow(report).to receive(:update_current_resource_report)
    end

    it "increments the resource count" do
      expect(report).to receive(:increment_resource_count)
      report.resource_up_to_date(new_resource, action)
    end

    context "when the resource is a nested resource" do
      it "does not nil out the current resource report" do
        allow(report).to receive(:nested_resource?).with(new_resource).and_return(true)
        expect(report).not_to receive(:update_current_resource_report)
        report.resource_up_to_date(new_resource, action)
      end
    end

    context "when the resource is not a nested resource" do
      it "does not nil out the current resource report" do
        allow(report).to receive(:nested_resource?).with(new_resource).and_return(false)
        expect(report).to receive(:update_current_resource_report).with(nil)
        report.resource_up_to_date(new_resource, action)
      end
    end
  end

  describe '#resource_skipped' do
    let(:new_resource) { double("new_resource") }
    let(:action)       { double("action") }
    let(:conditional)  { double("conditional") }

    before do
      allow(report).to receive(:increment_resource_count)
      allow(report).to receive(:nested_resource?)
      allow(report).to receive(:update_current_resource_report)
    end

    it "increments the resource count" do
      expect(report).to receive(:increment_resource_count)
      report.resource_skipped(new_resource, action, conditional)
    end

    context "when the resource is a nested resource" do
      it "does not nil out the current resource report" do
        allow(report).to receive(:nested_resource?).with(new_resource).and_return(true)
        expect(report).not_to receive(:update_current_resource_report)
        report.resource_skipped(new_resource, action, conditional)
      end
    end

    context "when the resource is not a nested resource" do
      it "does not nil out the current resource report" do
        allow(report).to receive(:nested_resource?).with(new_resource).and_return(false)
        expect(report).to receive(:update_current_resource_report).with(nil)
        report.resource_skipped(new_resource, action, conditional)
      end
    end
  end

  describe '#resource_updated' do
    it "increments the resource count" do
      expect(report).to receive(:increment_resource_count)
      report.resource_updated("new_resource", "action")
    end
  end

  describe '#resource_failed' do
    let(:new_resource) { double("new_resource") }
    let(:action)       { double("action") }
    let(:exception)    { double("exception") }

    it "increments the resource count" do
      expect(report).to receive(:increment_resource_count)
      report.resource_updated(new_resource, action)
    end
  end

end






