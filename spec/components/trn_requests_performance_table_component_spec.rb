require "rails_helper"

RSpec.describe TrnRequestsPerformanceTableComponent, type: :component do
  let(:total_grouped_requests) do
    { total: 6, cnt_trn_found: 2, cnt_no_match: 2, cnt_did_not_finish: 2 }
  end
  let(:grouped_request_counts) do
    [
      [
        "2 June",
        { total: 3, cnt_trn_found: 1, cnt_no_match: 1, cnt_did_not_finish: 1 },
      ],
      [
        "1 June",
        { total: 3, cnt_trn_found: 1, cnt_no_match: 1, cnt_did_not_finish: 1 },
      ],
    ]
  end

  subject do
    described_class.new(
      grouped_request_counts:,
      total_grouped_requests:,
      since: "last 7 days",
    )
  end

  it "renders a row per period" do
    expect(rendered_result_text).to include(
      "2 June1  (33%) 1  (33%) 1  (33%) 3 requests"
    )
    expect(rendered_result_text).to include(
      "1 June1  (33%) 1  (33%) 1  (33%) 3 requests"
    )

  end

  it "renders the totals row" do
    expect(rendered_result_text).to include(
      "Total (last 7 days)2  (33%) 2  (33%) 2  (33%) 6 requests"
    )
  end

  def rendered_result_text
    render_inline(subject).text
  end
end
