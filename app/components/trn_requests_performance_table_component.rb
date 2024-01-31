# frozen_string_literal: true
class TrnRequestsPerformanceTableComponent < ViewComponent::Base
  include PerformanceTableHelpers

  def initialize(grouped_request_counts:, total_grouped_requests:, since:)
    super
    @grouped_request_counts = grouped_request_counts
    @since = since
    @total_grouped_requests = total_grouped_requests
  end

  def call
    govuk_table(classes: "app-performance-table") do |table|
      table.with_head do |head|
        head.with_row do |row|
          row.with_cell(
            header: true,
            text: "Date",
            classes:
              "app-performance-table-column-divider app-performance-table-date-column",
          )
          row.with_cell(header: true, text: "TRN found")
          row.with_cell(header: true, text: "No match")
          row.with_cell(
            header: true,
            text: "Did not finish",
            classes: "app-performance-table-column-divider",
          )
          row.with_cell(
            header: true,
            text: "Total",
            classes: "govuk-!-padding-left-2",
          )
        end
      end
      table.with_body do |body|
        @grouped_request_counts.map do |period_label, counts|
          body.with_row do |row|
            row.with_cell(classes: "app-performance-table-column-divider") do
              period_label
            end
            row.with_cell { number_with_percentage_cell(counts, :cnt_trn_found) }
            row.with_cell { number_with_percentage_cell(counts, :cnt_no_match) }
            row.with_cell(classes: "app-performance-table-column-divider") do
              number_with_percentage_cell(counts, :cnt_did_not_finish)
            end
            row.with_cell { "#{number_with_delimiter(counts[:total])} requests" }
          end
        end
        body.with_row(classes: "app-performance-table-total-row") do |row|
          row.with_cell(
            header: true,
            classes: "app-performance-table-column-divider",
          ) { "Total (#{@since})" }
          row.with_cell do
            number_with_percentage_cell(@total_grouped_requests, :cnt_trn_found)
          end
          row.with_cell do
            number_with_percentage_cell(@total_grouped_requests, :cnt_no_match)
          end
          row.with_cell(classes: "app-performance-table-column-divider") do
            number_with_percentage_cell(
              @total_grouped_requests,
              :cnt_did_not_finish,
            )
          end
          row.with_cell do
            "#{number_with_delimiter(@total_grouped_requests[:total])} requests"
          end
        end
      end
    end
  end
end
