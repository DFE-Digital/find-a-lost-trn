require "rails_helper"

RSpec.describe SupportInterface::TrnRequestExportForm, type: :model do
  describe "#filename" do
    subject do
      described_class.new(
        time_period: Time.zone.local(2022, 12, 1, 12, 0, 0),
      ).filename
    end

    it { is_expected.to eq("2022_12_01_trn_requests.csv") }
  end

  describe "#months" do
    subject { described_class.new(time_period: nil).months }

    before { travel_to Time.zone.local(2022, 6, 18, 12, 0, 0) }

    after { travel_back }

    it "returns all months since the launch date" do
      is_expected.to eq(
        [
          %w[All all],
          ["June 2022", Time.zone.local(2022, 6, 1, 0, 0, 0)],
          ["May 2022", Time.zone.local(2022, 5, 1, 0, 0, 0)],
        ],
      )
    end
  end

  describe "#scope" do
    subject { described_class.new(time_period:).scope.to_a }

    let!(:prelaunch) do
      create(:trn_request, created_at: Time.zone.local(2022, 5, 3, 12, 0, 0))
    end
    let!(:may) do
      create(:trn_request, created_at: Time.zone.local(2022, 5, 4, 12, 0, 0))
    end
    let!(:june) do
      create(:trn_request, created_at: Time.zone.local(2022, 6, 1, 12, 0, 0))
    end

    context "when time_period is 'all'" do
      let(:time_period) { "all" }

      it { is_expected.to eq([may, june]) }
    end

    context "when time_period is a date" do
      let(:time_period) { Time.zone.local(2022, 6, 1, 0, 0, 0) }

      it { is_expected.to eq([june]) }
    end
  end
end
