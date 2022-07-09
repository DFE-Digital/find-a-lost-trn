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

  describe "#request_counts_by_day" do
    it "calculates found, not found and abandoned requests by day" do
      given_there_are_a_few_trns

      totals, counts_by_day =
        described_class.new(last_7_days).request_counts_by_day
      expect(totals).to eq(
        {
          total: 28,
          cnt_did_not_finish: 12,
          cnt_no_match: 0,
          cnt_trn_found: 16
        }
      )
      expect(counts_by_day.size).to eq 7
      expect(counts_by_day).to eq(
        [
          [
            "12 May",
            {
              cnt_trn_found: 1,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 1
            }
          ],
          [
            "11 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 2,
              total: 2
            }
          ],
          [
            "10 May",
            {
              cnt_trn_found: 3,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 3
            }
          ],
          [
            "9 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 4,
              total: 4
            }
          ],
          [
            "8 May",
            {
              cnt_trn_found: 5,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 5
            }
          ],
          [
            "7 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 6,
              total: 6
            }
          ],
          [
            "6 May",
            {
              cnt_trn_found: 7,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 7
            }
          ]
        ]
      )

      totals, counts_by_day =
        described_class.new(longer_than_last_7_days).request_counts_by_day
      expect(totals).to eq(
        {
          total: 45,
          cnt_did_not_finish: 20,
          cnt_no_match: 0,
          cnt_trn_found: 25
        }
      )

      expect(counts_by_day.size).to eq 29
      expect(counts_by_day.slice(8, 3)).to eq(
        [
          [
            "4 May",
            {
              cnt_trn_found: 9,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 9
            }
          ],
          [
            "3 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "2 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ]
        ]
      )
    end
  end

  describe "#duration_usage" do
    it "calculates duration results for requests that returned TRNs" do
      # requests where the user found TRNs
      durations_in_seconds = [240, 180, 120, 120]
      durations_in_seconds.each do |duration|
        create(
          :trn_request,
          :has_trn,
          created_at: Time.zone.today.beginning_of_day,
          checked_at: Time.zone.today.beginning_of_day + duration.seconds
        )
      end

      # requests where the TRN wasn't found
      create(
        :trn_request,
        created_at: Time.zone.today.beginning_of_day,
        checked_at: Time.zone.today.beginning_of_day + 6.minutes,
        trn: nil
      )

      averages, data = described_class.new(last_day).duration_usage
      expect(data.size).to eq 1
      expect(data).to eq([["12 May", "4 minutes", "3 minutes", "2 minutes"]])
      expect(averages).to eq(["4 minutes", "3 minutes", "2 minutes"])
    end
  end

  private

  def given_there_are_a_few_trns
    (0..8).each.with_index do |n, i|
      (i + 1).times do
        create(
          :trn_request,
          created_at: n.days.ago.beginning_of_day,
          trn: n.even? ? "1234567" : nil,
          checked_at: n.even? ? n.days.ago.beginning_of_day + 2.minutes : nil
        )
      end
    end
  end
end
