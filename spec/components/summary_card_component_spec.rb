require "rails_helper"

RSpec.describe SummaryCardComponent, type: :component do
  let(:rows) do
    [key: { text: "Character" }, value: { text: "Lando Calrissian" }]
  end

  it "renders a summary list component for rows" do
    result = render_inline(described_class.new(rows:))
    expect(result.css(".govuk-summary-list__value").text).to include(
      "Lando Calrissian",
    )
    expect(result.css(".govuk-summary-list__key").text).to include("Character")
  end

  it "renders content at the top of a summary card" do
    result = render_inline(described_class.new(rows:)) { "In a galaxy" }
    expect(result.text).to include("In a galaxy")
  end
end