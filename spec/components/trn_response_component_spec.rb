# frozen_string_literal: true
require "rails_helper"

RSpec.describe TrnResponseComponent, type: :component do
  subject(:component) { render_inline(described_class.new(trn_response:)) }

  let(:awarded_qts) { false }
  let(:first_name) { "Test" }
  let(:itt_provider_enrolled) { false }
  let(:last_name) { "User" }
  let(:ni_number) { "QC123456A" }
  let(:raw_result) do
    {
      "trn" => "2921020",
      "ni_number" => "QQ123456A",
      "qualified_teacher_status" => {
        "name" => "Trainee Teacher:DMS",
        "state" => "Active",
        "state_name" => "Active",
        "qts_date" => nil
      },
      "induction" => nil,
      "initial_teacher_training" => {
        "state" => "Active",
        "state_code" => "Active",
        "programme_start_date" => "2020-04-01T00:00:00Z",
        "programme_end_date" => "2020-10-10T00:00:00Z",
        "programme_type" => "Graduate Teacher Programme",
        "result" => "In Training",
        "subject1" => "computer science",
        "subject2" => nil,
        "subject3" => nil,
        "qualification" => nil,
        "subject1_code" => "100366",
        "subject2_code" => nil,
        "subject3_code" => nil
      },
      "qualifications" => [
        {
          "name" => "Higher Education",
          "date_awarded" => "2021-05-03T00:00:00Z",
          "he_qualification_name" => "First Degree",
          "he_subject1" => "computer science",
          "he_subject2" => nil,
          "he_subject3" => nil,
          "he_subject1_code" => "100366",
          "he_subject2_code" => nil,
          "he_subject3_code" => nil,
          "class" => "FirstClassHonours"
        }
      ],
      "name" => "Kevin E",
      "dob" => "1990-01-01T00:00:00",
      "active_alert" => false,
      "state" => "Active",
      "state_name" => "Active"
    }
  end
  let(:trn_request) do
    TrnRequest.new(
      awarded_qts:,
      first_name:,
      itt_provider_enrolled:,
      last_name:,
      ni_number:
    )
  end
  let(:trn_response) { TrnResponse.new(trn_request:, raw_result:) }

  it "renders name" do
    expect(component.text).to include("Kevin E")
  end

  it "renders NI number" do
    expect(component.text).to include("QQ 12 34 56 A")
  end

  it "renders the qualified teacher status" do
    expect(component.text).to include("DQT Have you been awarded QTS?")
    expect(component.text).to include("Yes")
  end

  it "renders the initial teacher training status" do
    expect(component.text).to include("DQT ITT Provider enrolled?")
    expect(component.text).to include("Yes")
  end

  context "with anonymised data" do
    subject(:component) do
      render_inline(described_class.new(trn_response:, anonymise: true))
    end

    it "renders anonymised name" do
      expect(component.text).to include("K**** E****")
    end

    it "renders anonymised NI number" do
      expect(component.text).to include("Q* ** ** ** A")
    end
  end

  context "when awarded_qts is the same" do
    let(:awarded_qts) { true }

    it "does not render QTS row" do
      expect(component.text).not_to include("DQT Have you been awarded QTS?")
    end
  end

  context "when the name is the same" do
    let(:first_name) { "Kevin" }
    let(:last_name) { "E" }

    it "does not render name" do
      expect(component.text).not_to include("DQT Name")
    end
  end

  context "when ni_number is the same" do
    let(:ni_number) { "QQ123456A" }

    it "does not render QTS row" do
      expect(component.text).not_to include("DQT National Insurance Number")
    end
  end

  context "when ITT provider is the same" do
    subject { component.text }

    let(:itt_provider_enrolled) { true }

    it { is_expected.not_to include("DQT ITT Provider enrolled?") }
  end
end
