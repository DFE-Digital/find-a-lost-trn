# frozen_string_literal: true
require 'gds_zendesk/client'
require 'gds_zendesk/dummy_client'

GDS_ZENDESK_CLIENT =
  if Rails.env.development? || Rails.env.test?
    GDSZendesk::DummyClient.new(development_mode: true, logger: Rails.logger)
  else
    GDSZendesk::Client.new(
      token: ENV['ZENDESK_TOKEN'],
      logger: Rails.logger,
      url: 'https://teachingregulationagency.zendesk.com/api/v2/',
    )
  end
