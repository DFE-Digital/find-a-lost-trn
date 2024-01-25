# frozen_string_literal: true
class ZendeskDeleteRequestsPerformanceTableComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :grouped_request_counts, :since, :total_grouped_requests

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
          row.with_cell(
            header: true,
            text: "Total",
            classes: "govuk-!-padding-left-2",
          )
        end
      end
      table.with_body do |body|
        grouped_request_counts.map do |period_label, counts|
          body.with_row do |row|
            row.with_cell(classes: "app-performance-table-column-divider") do
              period_label
            end
            row.with_cell do
              "#{number_with_delimiter(counts[:total])} delete requests"
            end
          end
        end

        body.with_row(classes: "app-performance-table-total-row") do |row|
          row.with_cell(
            header: true,
            classes: "app-performance-table-column-divider",
          ) { "Total (#{since})" }
          row.with_cell do
            "#{number_with_delimiter(total_grouped_requests[:total])} delete requests"
          end
        end
      end
    end
  end
end
