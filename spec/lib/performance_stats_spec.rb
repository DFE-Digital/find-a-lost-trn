# frozen_string_literal: true
require "rails_helper"

RSpec.describe PerformanceStats do
  before { Timecop.freeze(Time.zone.local(2022, 5, 12, 12, 0, 0)) }

  after { Timecop.return }

  let(:last_day) { Time.zone.today.beginning_of_day..Time.zone.now }

  let(:last_7_days) { 6.days.ago.beginning_of_day..Time.zone.now }

  let(:longer_than_last_7_days) { 4.weeks.ago.beginning_of_day..Time.zone.now }

  describe "without params" do
    it "asks for a time_period parameter" do
      expect { described_class.new(nil) }.to raise_error(
        ArgumentError,
        "time_period is not a Range"
      )
    end
  end

  describe "#live_service_usage" do
    it "calculates live service usage" do
      given_there_are_a_few_trns

      count, data = described_class.new(last_7_days).live_service_usage
      expect(count).to eq 28
      expect(data.size).to eq 8
      expect(data).to eq(
        [
          %w[Date Requests],
          ["12 May", 1],
          ["11 May", 2],
          ["10 May", 3],
          ["09 May", 4],
          ["08 May", 5],
          ["07 May", 6],
          ["06 May", 7]
        ]
      )

      count, data =
        described_class.new(longer_than_last_7_days).live_service_usage
      expect(count).to eq 45
      expect(data.size).to eq 30
      expect(data.take(12)).to eq(
        [
          %w[Date Requests],
          ["12 May", 1],
          ["11 May", 2],
          ["10 May", 3],
          ["09 May", 4],
          ["08 May", 5],
          ["07 May", 6],
          ["06 May", 7],
          ["05 May", 8],
          ["04 May", 9],
          ["03 May", 0],
          ["02 May", 0]
        ]
      )
    end
  end

  describe "#submission results" do
    it "calculates submission stats" do
      given_there_are_a_few_trns

      count, data = described_class.new(last_7_days).submission_results
      expect(count).to eq 12
      expect(data.size).to eq 8
      expect(data).to eq(
        [
          ["Date", "TRNs found", "Zendesk tickets opened"],
          ["12 May", 0, 0],
          ["11 May", 2, 0],
          ["10 May", 0, 0],
          ["09 May", 4, 0],
          ["08 May", 0, 0],
          ["07 May", 6, 0],
          ["06 May", 0, 0]
        ]
      )

      count, data =
        described_class.new(longer_than_last_7_days).submission_results
      expect(count).to eq 20
      expect(data.size).to eq 30
      expect(data.take(12)).to eq(
        [
          ["Date", "TRNs found", "Zendesk tickets opened"],
          ["12 May", 0, 0],
          ["11 May", 2, 0],
          ["10 May", 0, 0],
          ["09 May", 4, 0],
          ["08 May", 0, 0],
          ["07 May", 6, 0],
          ["06 May", 0, 0],
          ["05 May", 8, 0],
          ["04 May", 0, 0],
          ["03 May", 0, 0],
          ["02 May", 0, 0]
        ]
      )
    end
  end

  describe "#duration_usage" do
    it "calculates duration results" do
      durations_in_seconds = [240, 180, 120, 120]
      durations_in_seconds.each do |duration|
        create(
          :trn_request,
          created_at: Time.zone.today.beginning_of_day,
          checked_at: Time.zone.today.beginning_of_day + duration.seconds,
          trn: "1234567"
        )
      end

      data = described_class.new(last_day).duration_usage
      expect(data.size).to eq 1
      expect(data).to eq(
        [
          ["12 May", "4 minutes", "3 minutes", "2 minutes"]
        ]
      )
    end
  end

  private

  def given_there_are_a_few_trns
    (0..8).each.with_index do |n, i|
      (i + 1).times do
        create(
          :trn_request,
          created_at: n.days.ago.beginning_of_day,
          trn: n.odd? ? "1234567" : nil
        )
      end
    end
  end
end
