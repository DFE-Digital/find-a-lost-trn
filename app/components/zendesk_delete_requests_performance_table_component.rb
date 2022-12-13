# frozen_string_literal: true
class ZendeskDeleteRequestsPerformanceTableComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :grouped_request_counts, :since, :total_grouped_requests

  def call
    govuk_table(classes: "app-performance-table") do |table|
      table.head do |head|
        head.row do |row|
          row.cell(
            header: true,
            text: "Date",
            classes:
              "app-performance-table-column-divider app-performance-table-date-column",
          )
          row.cell(
            header: true,
            text: "Total",
            classes: "govuk-!-padding-left-2",
          )
        end
      end
      table.body do |body|
        grouped_request_counts.map do |period_label, counts|
          body.row do |row|
            row.cell(classes: "app-performance-table-column-divider") do
              period_label
            end
            row.cell do
              "#{number_with_delimiter(counts[:total])} delete requests"
            end
          end
        end

        body.row(classes: "app-performance-table-total-row") do |row|
          row.cell(
            header: true,
            classes: "app-performance-table-column-divider",
          ) { "Total (#{since})" }
          row.cell do
            "#{number_with_delimiter(total_grouped_requests[:total])} delete requests"
          end
        end
      end
    end
  end
end
