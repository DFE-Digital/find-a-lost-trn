module SummaryListHelpers
  def within_summary_row(row_description, &block)
    within(page.find(".govuk-summary-list__row", text: row_description)) do
      block.call
    end
  end
end
