# frozen_string_literal: true
require "rails_helper"

RSpec.describe TrnDetailsComponent, type: :component do
  let(:has_ni_number) { true }
  let(:itt_provider_enrolled) { true }
  let(:ni_number) { "QC123456A" }
  let(:email) { "test@example.com" }
  let(:awarded_qts) { true }
  let(:trn_from_user) { "1234567" }
  let(:from_get_an_identity) { false }
  let(:preferred_first_name) { "Ray" }
  let(:preferred_last_name) { "Purchase" }
  let(:trn_request) do
    TrnRequest.new(
      awarded_qts:,
      date_of_birth: 20.years.ago.to_date,
      email:,
      from_get_an_identity:,
      first_name: "Test",
      has_ni_number:,
      itt_provider_enrolled:,
      itt_provider_name: "Big SCITT",
      last_name: "User",
      ni_number:,
      previous_last_name: "Smith",
      trn_from_user:,
      preferred_first_name:,
      preferred_last_name:,
    )
  end
  let(:component) { render_inline(described_class.new(trn_request:)) }

  it "renders name" do
    expect(component.text).to include("Test User")
  end

  it "renders previous name" do
    expect(component.text).to include("Test Smith")
  end

  it "renders date of birth" do
    expect(component.text).to include(
      20.years.ago.to_date.to_fs(:long_ordinal_uk),
    )
  end

  it "renders NI number" do
    expect(component.text).to include("QC 12 34 56 A")
  end

  it "renders the qualified teacher status" do
    expect(component.text).to include("Have you been awarded QTS?")
    expect(component.text).to include("Yes")
  end

  it "renders ITT provider" do
    expect(component.text).to include("Big SCITT")
  end

  it "renders email" do
    expect(component.text).to include("test­@example­.com") # NB: This is test&shy;@example&shy;.com
  end

  context "when a TRN from user is provided" do
    it { expect(component.text).to_not include("1234567") }

    context "when from Get An Identity" do
      let(:from_get_an_identity) { true }

      it "renders TRN from user" do
        expect(component.text).to include("1234567")
      end

      it "renders preferred name" do
        expect(component.text).to include("Ray Purchase")
      end
    end
  end

  it "does not render change buttons" do
    expect(component.text).not_to include("Change")
  end

  context "with actions" do
    let(:component) do
      render_inline(described_class.new(trn_request:, actions: true))
    end

    it "renders change name" do
      expect(component.text).to include("Change name")
    end

    it "renders change previous name" do
      expect(component.text).to include("Change previous name")
    end

    it "renders change date of birth" do
      expect(component.text).to include("Change date of birth")
    end

    it "renders change NI number" do
      expect(component.text).to include("Change national insurance number")
    end

    it "renders change ITT provider" do
      expect(component.text).to include("Change teacher training provider")
    end

    it "renders change email" do
      expect(component.text).to include("Change email")
    end

    context "when an email address has been supplied by Identity" do
      before do
        allow(trn_request).to receive(:from_get_an_identity).and_return(true)
      end

      it "does not render change email" do
        expect(component.text).to_not include("Change email")
      end
    end
  end

  context "with anonymised data" do
    let(:from_get_an_identity) { true }
    let(:component) do
      render_inline(described_class.new(trn_request:, anonymise: true))
    end

    it "renders anonymised name" do
      expect(component.text).to include("T**** U****")
    end

    it "renders anonymised preferred name" do
      expect(component.text).to include("R**** P****")
    end

    it "renders anonymised previous name" do
      expect(component.text).to include("T**** S****")
    end

    it "renders anonymised date of birth" do
      expect(component.text).to include("** ** ****")
    end

    it "renders anonymised NI number" do
      expect(component.text).to include("Q* ** ** ** A")
    end

    it "renders ITT provider" do
      expect(component.text).to include("Big SCITT")
    end

    it "renders anonymised email" do
      expect(component.text).to include("t****@****.com")
    end
  end

  context "with both actions and anonymised data" do
    it "raises an error" do
      expect {
        render_inline(
          described_class.new(trn_request:, anonymise: true, actions: true),
        )
      }.to raise_error(ArgumentError)
    end
  end

  context "when preferred name is same as name" do
    let(:from_get_an_identity) { true }
    let(:preferred_first_name) { "" }
    let(:preferred_last_name) { "" }

    it 'renders "Same as name"' do
      expect(component.text).to include("Same as name")
    end
  end

  context "when NI number not available" do
    let(:has_ni_number) { false }
    let(:ni_number) { nil }

    it 'renders "No"' do
      expect(component.text).to include("No")
    end
  end

  context "when NI number not provided" do
    let(:has_ni_number) { true }
    let(:ni_number) { nil }

    it 'renders "Not provided"' do
      expect(component.text).to include("Not provided")
    end
  end

  context "when awarded_qts is nil" do
    let(:awarded_qts) { nil }

    it "does not render QTS row" do
      expect(component.text).not_to include("Have you been awarded QTS?")
    end
  end

  context "when email is nil" do
    let(:email) { nil }

    it 'renders "Not provided"' do
      expect(component.text).to include("Email addressNot provided")
    end
  end

  context "when ITT provider not enrolled" do
    subject { component.text }

    let(:itt_provider_enrolled) { false }

    it do
      is_expected.to include(
        "Did a university, School Centred Initial Teacher Training (SCITT) provider or school award your QTS?",
      )
    end
    it { is_expected.to include("No, I was awarded QTS another way") }
  end

  context "when TRN from user is not provided" do
    let(:trn_from_user) { "" }

    it { expect(component.text).to_not include("I don’t know my TRN") }

    context "when from Get An Identity" do
      let(:from_get_an_identity) { true }

      it "does renders that the TRN was not provided" do
        expect(component.text).to include("I don’t know my TRN")
      end
    end
  end

  context "when a TRN from user is nil" do
    let(:trn_from_user) { nil }

    it { expect(component.text).to_not include("I don’t know my TRN") }

    context "when from Get An Identity" do
      let(:from_get_an_identity) { true }

      it "does not render TRN from user" do
        expect(component.text).to_not include("I don’t know my TRN")
      end
    end
  end
end
