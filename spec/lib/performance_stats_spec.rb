# frozen_string_literal: true
require "rails_helper"

RSpec.describe PerformanceStats do
  before { Timecop.freeze(Time.zone.local(2022, 5, 12, 12, 0, 0)) }

  after { Timecop.return }

  let(:last_7_days_and_today) { 1.week.ago.beginning_of_day..Time.zone.now }

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
      create_list(:trn_request, 2, :has_trn, created_at: 2.hours.ago) # counts against 12 May
      create_list(
        :trn_request,
        3,
        :has_zendesk_ticket,
        created_at: 1.day.ago + 2.hours
      ) # counts against 11 May
      create_list(
        :trn_request,
        4,
        trn: nil,
        zendesk_ticket_id: nil,
        created_at: 2.days.ago + 2.hours
      ) # counts against 10 May
      create_list(
        :trn_request,
        5,
        trn: nil,
        zendesk_ticket_id: nil,
        created_at: 1.month.ago + 2.hours
      ) # counts against April, should not affect the counts as it falls outside the window

      totals, counts_by_day =
        described_class.new(last_7_days_and_today).request_counts_by_day
      expect(totals).to eq(
        { total: 9, cnt_did_not_finish: 4, cnt_no_match: 3, cnt_trn_found: 2 }
      )
      expect(counts_by_day.size).to eq 8
      expect(counts_by_day).to eq(
        [
          [
            "12 May",
            {
              cnt_trn_found: 2,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 2
            }
          ],
          [
            "11 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 3,
              cnt_did_not_finish: 0,
              total: 3
            }
          ],
          [
            "10 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 4,
              total: 4
            }
          ],
          [
            "9 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "8 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "7 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "6 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "5 May",
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

    it "counts a user who got to the end but didn't raise a zendesk ticket as an abandonment" do
      create(
        :trn_request,
        created_at: Time.zone.today.beginning_of_day,
        checked_at: Time.zone.today.beginning_of_day + 2.minutes,
        zendesk_ticket_id: nil
      )

      totals, = described_class.new(last_7_days_and_today).request_counts_by_day

      expect(totals).to eq(
        { total: 1, cnt_did_not_finish: 1, cnt_no_match: 0, cnt_trn_found: 0 }
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

      averages, data = described_class.new(last_7_days_and_today).duration_usage
      expect(data.first).to eq(
        ["12 May", "4 minutes", "3 minutes", "2 minutes"]
      )
      expect(averages).to eq(["4 minutes", "3 minutes", "2 minutes"])
    end
  end
end
