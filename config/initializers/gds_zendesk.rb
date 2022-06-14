# frozen_string_literal: true
require 'gds_zendesk/client'
require 'gds_zendesk/dummy_client'

module DummyTicketExtensions
  # The create! method in the DummyTicket class does not actually return a
  # real-ish Zendesk ticket. This is a monkey patch to call the original method
  # and then return a ticket instance.
  def create!(options)
    super

    ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42)
  end

  def find(id)
    ticket = ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: id)
    ticket.comments = [
      ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 1, body: 'Example'),
      ZendeskAPI::Ticket::Comment.new(GDS_ZENDESK_CLIENT, id: 2, body: 'Your TRN is **2921020**'),
    ]
    ticket
  end
end

module GDSZendesk
  class DummyTicket
    prepend DummyTicketExtensions
  end
end

GDS_ZENDESK_CLIENT =
  if HostingEnvironment.test_environment?
    GDSZendesk::DummyClient.new(development_mode: true, logger: Rails.logger)
  else
    GDSZendesk::Client.new(
      username: ENV.fetch('ZENDESK_USER', nil),
      token: ENV.fetch('ZENDESK_TOKEN', nil),
      logger: Rails.logger,
      url: 'https://teachingregulationagency.zendesk.com/api/v2/',
    )
  end
