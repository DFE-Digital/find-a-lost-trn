# frozen_string_literal: true
class TrnRequestsPerformanceTableComponent < ViewComponent::Base
  def initialize(grouped_request_counts:, total_grouped_requests:, since:)
    super
    @grouped_request_counts = grouped_request_counts
    @since = since
    @total_grouped_requests = total_grouped_requests
  end

  def call
    govuk_table(classes: "app-performance-table") do |table|
      table.head do |head|
        head.row do |row|
          row.cell(
            header: true,
            text: "Date",
            classes:
              "app-performance-table-column-divider app-performance-table-date-column"
          )
          row.cell(header: true, text: "TRN found")
          row.cell(header: true, text: "No match")
          row.cell(
            header: true,
            text: "Did not finish",
            classes: "app-performance-table-column-divider"
          )
          row.cell(
            header: true,
            text: "Total",
            classes: "govuk-!-padding-left-2"
          )
        end
      end
      table.body do |body|
        @grouped_request_counts.map do |period_label, counts|
          body.row do |row|
            row.cell(classes: "app-performance-table-column-divider") do
              period_label
            end
            row.cell { number_with_percentage_cell(counts, :cnt_trn_found) }
            row.cell { number_with_percentage_cell(counts, :cnt_no_match) }
            row.cell(classes: "app-performance-table-column-divider") do
              number_with_percentage_cell(counts, :cnt_did_not_finish)
            end
            row.cell { "#{number_with_delimiter(counts[:total])} requests" }
          end
        end
        body.row(classes: "app-performance-table-total-row") do |row|
          row.cell(
            header: true,
            classes: "app-performance-table-column-divider"
          ) { "Total (#{@since})" }
          row.cell do
            number_with_percentage_cell(@total_grouped_requests, :cnt_trn_found)
          end
          row.cell do
            number_with_percentage_cell(@total_grouped_requests, :cnt_no_match)
          end
          row.cell(classes: "app-performance-table-column-divider") do
            number_with_percentage_cell(
              @total_grouped_requests,
              :cnt_did_not_finish
            )
          end
          row.cell do
            "#{number_with_delimiter(@total_grouped_requests[:total])} requests"
          end
        end
      end
    end
  end

  private

  def trn_request_count_percent(attributes, numerator_key)
    if attributes[:total].zero?
      ""
    else
      percentage =
        number_to_percentage(
          100 * attributes[numerator_key].fdiv(attributes[:total]),
          precision: 0
        )
      "(#{percentage})"
    end
  end

  def number_with_percentage_cell(counts, key)
    "#{number_with_delimiter(counts[key])} <span class=\"govuk-hint govuk-!-font-size-16\">#{
      trn_request_count_percent(counts, key)
    }</span>".html_safe
  end
end
