# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FetchTrnFromZendesk, type: :model do
  it { is_expected.to validate_presence_of(:trn_request) }

  describe '#call' do
    subject(:fetch) { described_class.new(trn_request: trn_request).call }

    let(:trn_request) { create(:trn_request, :has_zendesk_ticket) }
    let(:raw_result) { { 'trn' => '2921020' } }

    before { allow(DqtApi).to receive(:find_teacher!).and_return(raw_result) }

    it 'updates the provided TrnRequest with a TRN' do
      expect { fetch }.to change(trn_request, :trn).from(nil).to('2921020')
    end

    context 'when there is no TRN in the comments' do
      let(:ticket) do
        ZendeskAPI::Ticket
          .new(GDS_ZENDESK_CLIENT, id: 1)
          .tap do |ticket|
            ticket.comments = [ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 1, body: 'Example')]
          end
      end

      before { allow(GDS_ZENDESK_CLIENT.ticket).to receive(:find).and_return(ticket) }

      it 'does not update the TrnRequest' do
        expect { fetch }.not_to change(trn_request, :trn)
      end
    end

    context 'when the Zendesk ticket last comment is a customer response' do
      let(:ticket) do
        ZendeskAPI::Ticket
          .new(GDS_ZENDESK_CLIENT, id: 1)
          .tap do |ticket|
            ticket.comments = [
              ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 1, body: 'Example'),
              ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 2, body: 'Your TRN is **2921020**'),
              ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 3, body: 'Thanks'),
            ]
          end
      end

      before { allow(GDS_ZENDESK_CLIENT.ticket).to receive(:find).and_return(ticket) }

      it 'updates the provided TrnRequest with a TRN' do
        expect { fetch }.to change(trn_request, :trn).from(nil).to('2921020')
      end
    end

    context 'when there are multiple no matching comments on a ticket' do
      let(:ticket) do
        ZendeskAPI::Ticket
          .new(GDS_ZENDESK_CLIENT, id: 1)
          .tap do |ticket|
            ticket.comments = [
              ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 1, body: 'Example'),
              ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 2, body: 'Thanks'),
            ]
          end
      end

      before { allow(GDS_ZENDESK_CLIENT.ticket).to receive(:find).and_return(ticket) }

      it 'does not update the TrnRequest' do
        expect { fetch }.not_to change(trn_request, :trn)
      end
    end
  end
end
