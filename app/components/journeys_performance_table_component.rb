# frozen_string_literal: true
class JourneysPerformanceTableComponent < ViewComponent::Base
  include PerformanceTableHelpers

  def initialize(which_questions_were_needed)
    super
    @which_questions_were_needed = which_questions_were_needed
  end

  def call
    govuk_table(classes: "app-performance-table") do |table|
      table.caption(
        size: "m",
        text: "Journeys through Find a lost TRN (today and the last 7 days)",
      )

      table.head do |head|
        head.row do |row|
          row.cell(header: true, text: "Number of questions asked")
          row.cell(header: true, text: "Number of users")
        end
      end
      table.body do |body|
        body.row do |row|
          row.cell do
            '3 questions<br /><span class="govuk-hint">Email address, name and date of birth</span>'.html_safe
          end
          row.cell do
            number_with_percentage_cell(
              @which_questions_were_needed,
              :three_questions,
              label: "user",
            )
          end
        end
        body.row do |row|
          row.cell do
            '4 questions<br /><span class="govuk-hint">+ National Insurance number</span>'.html_safe
          end
          row.cell do
            number_with_percentage_cell(
              @which_questions_were_needed,
              :four_questions,
              label: "user",
            )
          end
        end
        body.row do |row|
          row.cell do
            '5 questions (with a match)<br /><span class="govuk-hint">+ ITT provider</span>'.html_safe
          end
          row.cell do
            number_with_percentage_cell(
              @which_questions_were_needed,
              :five_questions_matched,
              label: "user",
            )
          end
        end
        body.row do |row|
          row.cell do
            '5 questions (without a match)<br /><span class="govuk-hint">+ ITT provider</span>'.html_safe
          end
          row.cell do
            number_with_percentage_cell(
              @which_questions_were_needed,
              :five_questions_nomatch,
              label: "user",
            )
          end
        end
      end
    end
  end
end
