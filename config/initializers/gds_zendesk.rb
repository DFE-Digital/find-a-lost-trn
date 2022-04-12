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
end

module GDSZendesk
  class DummyTicket
    prepend DummyTicketExtensions
  end
end

GDS_ZENDESK_CLIENT =
  if Rails.env.development? || Rails.env.test?
    GDSZendesk::DummyClient.new(development_mode: true, logger: Rails.logger)
  else
    GDSZendesk::Client.new(
      username: ENV['ZENDESK_USER'],
      token: ENV['ZENDESK_TOKEN'],
      logger: Rails.logger,
      url: 'https://teachingregulationagency.zendesk.com/api/v2/',
    )
  end
