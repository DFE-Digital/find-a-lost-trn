# frozen_string_literal: true
require "rails_helper"

RSpec.describe PerformanceStats do
  before { Timecop.freeze(Time.zone.local(2022, 5, 12, 12, 0, 0)) }

  after { Timecop.return }

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

      totals, counts_by_day = described_class.new.request_counts_by_day
      expect(totals).to eq(
        { total: 9, cnt_did_not_finish: 4, cnt_no_match: 3, cnt_trn_found: 2 }
      )
      expect(counts_by_day.size).to eq 8
      expect(counts_by_day).to eq(
        [
          [
            "Thursday 12 May",
            {
              cnt_trn_found: 2,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 2
            }
          ],
          [
            "Wednesday 11 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 3,
              cnt_did_not_finish: 0,
              total: 3
            }
          ],
          [
            "Tuesday 10 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 4,
              total: 4
            }
          ],
          [
            "Monday 9 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "Sunday 8 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "Saturday 7 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "Friday 6 May",
            {
              cnt_trn_found: 0,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 0
            }
          ],
          [
            "Thursday 5 May",
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

      totals, = described_class.new.request_counts_by_day

      expect(totals).to eq(
        { total: 1, cnt_did_not_finish: 1, cnt_no_match: 0, cnt_trn_found: 0 }
      )
    end
  end

  describe "#request_counts_by_month" do
    it "calculates found, not found and abandoned requests by month" do
      Timecop.freeze(Time.zone.local(2022, 6, 1, 12, 0, 0))

      create_list(:trn_request, 2, :has_trn, created_at: Date.new(2022, 6, 1))
      create_list(
        :trn_request,
        3,
        :has_zendesk_ticket,
        created_at: Date.new(2022, 5, 12)
      )

      # shouldn't appear as they're prior to service launch on 4 May 2022
      create_list(
        :trn_request,
        5,
        trn: nil,
        zendesk_ticket_id: nil,
        created_at: Date.new(2022, 5, 1)
      )

      totals, counts_by_month = described_class.new.request_counts_by_month
      expect(totals).to eq(
        { total: 5, cnt_did_not_finish: 0, cnt_no_match: 3, cnt_trn_found: 2 }
      )
      expect(counts_by_month.size).to eq 2
      expect(counts_by_month).to eq(
        [
          [
            "June 2022",
            {
              cnt_trn_found: 2,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 2
            }
          ],
          [
            "May 2022",
            {
              cnt_trn_found: 0,
              cnt_no_match: 3,
              cnt_did_not_finish: 0,
              total: 3
            }
          ]
        ]
      )
    end

    it "calculates requests only for a rolling 12-month window including the current month" do
      Timecop.freeze(Time.zone.local(2023, 7, 12, 12, 0, 0))

      create_list(:trn_request, 2, :has_trn, created_at: Time.zone.now) # against July 2023
      create_list(:trn_request, 3, :has_trn, created_at: 1.month.ago) # against June 2023
      create_list(:trn_request, 4, :has_trn, created_at: 12.months.ago) # against July 2022

      # shouldn't appear as it's outside the rolling window
      create_list(:trn_request, 5, :has_trn, created_at: 13.months.ago) # against June 2022

      totals, counts_by_month = described_class.new.request_counts_by_month
      expect(totals).to eq(
        { total: 9, cnt_did_not_finish: 0, cnt_no_match: 0, cnt_trn_found: 9 }
      )
      expect(counts_by_month.size).to eq 3
      expect(counts_by_month).to eq(
        [
          [
            "July 2023",
            {
              cnt_trn_found: 2,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 2
            }
          ],
          [
            "June 2023",
            {
              cnt_trn_found: 3,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 3
            }
          ],
          [
            "July 2022",
            {
              cnt_trn_found: 4,
              cnt_no_match: 0,
              cnt_did_not_finish: 0,
              total: 4
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

      averages, data = described_class.new.duration_usage
      expect(data.first).to eq(
        ["Thursday 12 May", "4 minutes", "3 minutes", "2 minutes"]
      )
      expect(averages).to eq(["4 minutes", "3 minutes", "2 minutes"])
    end
  end

  describe "#journeys" do
    it "buckets complete journeys through the service" do
      create(:trn_request, trn: nil, zendesk_ticket_id: nil) # drop out, should not be counted
      create(:trn_request, :has_trn, has_ni_number: nil) # success after 3 questions
      create(:trn_request, :has_trn, has_ni_number: true, awarded_qts: nil) # success after 4 questions
      create(
        :trn_request,
        :has_trn,
        has_ni_number: true,
        awarded_qts: true,
        zendesk_ticket_id: nil
      ) # success after 5 questions
      create(:trn_request, :has_zendesk_ticket, awarded_qts: true) # zendesk after 5 questions

      expect(described_class.new.journeys).to eq(
        total: 4,
        three_questions: 1,
        four_questions: 1,
        five_questions_matched: 1,
        five_questions_nomatch: 1
      )
    end
  end
end
