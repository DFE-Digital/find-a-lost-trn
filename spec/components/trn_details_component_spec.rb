# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TrnDetailsComponent, type: :component do
  let(:has_ni_number) { true }
  let(:ni_number) { 'QC123456A' }
  let(:email) { 'test@example.com' }
  let(:trn_request) do
    TrnRequest.new(
      date_of_birth: 20.years.ago.to_date,
      email: email,
      first_name: 'Test',
      has_ni_number: has_ni_number,
      itt_provider_enrolled: true,
      itt_provider_name: 'Big SCITT',
      last_name: 'User',
      ni_number: ni_number,
      previous_last_name: 'Smith',
    )
  end
  let(:component) { render_inline(described_class.new(trn_request: trn_request)) }

  it 'renders name' do
    expect(component.text).to include('Test User')
  end

  it 'renders previous name' do
    expect(component.text).to include('Test Smith')
  end

  it 'renders date of birth' do
    expect(component.text).to include(20.years.ago.to_date.to_fs(:long_ordinal_uk))
  end

  it 'renders NI number' do
    expect(component.text).to include('QC 12 34 56 A')
  end

  it 'renders ITT provider' do
    expect(component.text).to include('Big SCITT')
  end

  it 'renders email' do
    expect(component.text).to include('test­@example­.com') # NB: This is test&shy;@example&shy;.com
  end

  it 'does not render change buttons' do
    expect(component.text).not_to include('Change')
  end

  context 'with actions' do
    let(:component) { render_inline(described_class.new(trn_request: trn_request, actions: true)) }

    it 'renders change name' do
      expect(component.text).to include('Change name')
    end

    it 'renders change previous name' do
      expect(component.text).to include('Change previous name')
    end

    it 'renders change date of birth' do
      expect(component.text).to include('Change date of birth')
    end

    it 'renders change NI number' do
      expect(component.text).to include('Change national insurance number')
    end

    it 'renders change ITT provider' do
      expect(component.text).to include('Change teacher training provider')
    end

    it 'renders change email' do
      expect(component.text).to include('Change email')
    end
  end

  context 'with anonymised data' do
    let(:component) { render_inline(described_class.new(trn_request: trn_request, anonymise: true)) }

    it 'renders anonymised name' do
      expect(component.text).to include('T**** U****')
    end

    it 'renders anonymised previous name' do
      expect(component.text).to include('T**** S****')
    end

    it 'renders anonymised date of birth' do
      expect(component.text).to include('** ** ****')
    end

    it 'renders anonymised NI number' do
      expect(component.text).to include('Q* ** ** ** A')
    end

    it 'renders ITT provider' do
      expect(component.text).to include('Big SCITT')
    end

    it 'renders anonymised email' do
      expect(component.text).to include('t****@****.com')
    end
  end

  context 'with both actions and anonymised data' do
    it 'raises an error' do
      expect do
        render_inline(described_class.new(trn_request: trn_request, anonymise: true, actions: true))
      end.to raise_error(ArgumentError)
    end
  end

  context 'when NI number not available' do
    let(:has_ni_number) { false }
    let(:ni_number) { nil }

    it 'renders "No"' do
      expect(component.text).to include('No')
    end
  end

  context 'when NI number not provided' do
    let(:has_ni_number) { true }
    let(:ni_number) { nil }

    it 'renders "Not provided"' do
      expect(component.text).to include('Not provided')
    end
  end

  context 'when email is nil' do
    let(:email) { nil }

    it 'renders "Not provided"' do
      expect(component.text).to include('Email addressNot provided')
    end
  end
end
