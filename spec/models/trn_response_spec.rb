# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TrnResponse, type: :model do
  subject(:trn_response) do
    described_class.new(trn_request:)
  end

  let(:trn_request) { build(:trn_request) }

  it { is_expected.to be_valid }
  it { is_expected.to belong_to(:trn_request) }

  describe '#diff' do
    subject { trn_response.diff }

    let(:trn_response) { described_class.new(trn_request:, raw_result:) }

    context 'without a raw_result' do
      let(:raw_result) { nil }

      it { is_expected.to be_nil }
    end

    context 'with a raw_result' do
      let(:raw_result) do
        {
          'trn'=>'2921020',
          'ni_number'=>'AA123456A',
          'qualified_teacher_status'=>{'name'=>'Trainee Teacher:DMS', 'state'=>'Active', 'state_name'=>'Active', 
'qts_date'=>nil},
          'induction'=>nil,
          'initial_teacher_training'=>
           {'state'=>'Active',
            'state_code'=>'Active',
            'programme_start_date'=>'2020-04-01T00:00:00Z',
            'programme_end_date'=>'2020-10-10T00:00:00Z',
            'programme_type'=>'Graduate Teacher Programme',
            'result'=>'In Training',
            'subject1'=>'computer science',
            'subject2'=>nil,
            'subject3'=>nil,
            'qualification'=>nil,
            'subject1_code'=>'100366',
            'subject2_code'=>nil,
            'subject3_code'=>nil},
          'qualifications'=>
           [{'name'=>'Higher Education',
             'date_awarded'=>'2021-05-03T00:00:00Z',
             'he_qualification_name'=>'First Degree',
             'he_subject1'=>'computer science',
             'he_subject2'=>nil,
             'he_subject3'=>nil,
             'he_subject1_code'=>'100366',
             'he_subject2_code'=>nil,
             'he_subject3_code'=>nil,
             'class'=>'FirstClassHonours'}],
          'name'=>'Kevin E',
          'dob'=>'1990-01-01T00:00:00',
          'active_alert'=>false,
          'state'=>'Active',
          'state_name'=>'Active'
        }
      end

      it { is_expected.to eq({ ni_number: 'AA123456A', name: 'Kevin E' }) }
    end
  end
end
