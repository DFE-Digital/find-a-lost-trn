# frozen_string_literal: true
require 'rails_helper'
require 'clockwork/test'
require 'sidekiq'

RSpec.describe Clockwork, clockwork: true do
  around { |example| Timecop.freeze(Time.zone.now.beginning_of_week.change(hour: 8, min: 0, sec: 0)) { example.run } }

  after { Clockwork::Test.clear! }

  describe 'performance.alert' do
    let(:job) { PerformanceAlertJob }
    let(:name) { 'performance.alert' }

    it 'runs the job every Monday' do
      Clockwork::Test.run(end_time: 8.days.from_now, tick_speed: 1.hour)
      expect(Clockwork::Test.times_run(name)).to eq 2
    end

    it 'queues a PerformanceAlertJob' do
      allow(job).to receive(:perform_later)
      Clockwork::Test.run(end_time: 2.hours.from_now, tick_speed: 1.hour)
      Clockwork::Test.block_for(name).call
      expect(job).to have_received(:perform_later)
    end
  end

  it 'executes without error' do
    Clockwork::Test.run(end_time: 2.hours.from_now, tick_speed: 1.hour)

    Clockwork::Test
      .manager
      .send(:history)
      .jobs
      .each { |job| expect { Clockwork::Test.block_for(job).call }.not_to raise_error }
  end
end
