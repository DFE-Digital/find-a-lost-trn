# frozen_string_literal: true
require "gds_zendesk/client"
require "gds_zendesk/dummy_client"

class ExtendedDummyClient
  def initialize(logger)
    @logger = logger
  end

  def connection
    Struct.new(:get).new
  end

  def tickets
    self
  end

  def search(_params)
    fetch
  end

  def destroy_many(_params)
    self
  end

  def fetch(*args)
    fetch!(*args)
  end

  def fetch!(*_args)
    ZendeskAPI::Collection
      .new(self, ZendeskAPI::Ticket)
      .tap do |collection|
        collection.instance_variable_set(
          :@resources,
          [
            ZendeskAPI::Ticket.new(
              GDS_ZENDESK_CLIENT,
              id: 42,
              created_at: (6.months + 8.days).ago,
              updated_at: (6.months + 1.day).ago,
              custom_fields: [
                { id: 4_419_328_659_089, value: "Foo" },
                { id: 4_562_126_876_049, value: "Bar" },
              ],
              group: {
                name: "Some group",
              },
            ),
          ],
        )
        collection.instance_variable_set(:@count, 1)
      end
  end
end

module DummyClientExtensions
  attr_reader :zendesk_client, :ticket

  def initialize(options)
    @logger = options[:logger] || NullLogger.instance
    @ticket = GDSZendesk::DummyTicket.new(@logger)
    @users = GDSZendesk::DummyUsers.new(@logger)
    @zendesk_client = ExtendedDummyClient.new(@logger)
  end
end

module DummyTicketExtensions
  def count!
    1
  end

  # The create! method in the DummyTicket class does not actually return a
  # real-ish Zendesk ticket. This is a monkey patch to call the original method
  # and then return a ticket instance.
  def create!(options)
    super

    ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id: 42)
  end

  def find(id:)
    ticket = ZendeskAPI::Ticket.new(GDS_ZENDESK_CLIENT, id:)
    ticket.comments = [
      ZendeskAPI::Ticket::Comment.new(
        GDS_ZENDESK_CLIENT,
        id: 1,
        body: "Example",
      ),
      ZendeskAPI::Ticket::Comment.new(
        GDS_ZENDESK_CLIENT,
        id: 2,
        body: "Your TRN is **2921020**",
      ),
    ]
    ticket
  end

  def find!(id:)
    find(id:)
  end
end

module GDSZendesk
  class DummyClient
    prepend DummyClientExtensions
  end

  class DummyTicket
    prepend DummyTicketExtensions
  end
end

GDS_ZENDESK_CLIENT =
  if HostingEnvironment.test_environment?
    GDSZendesk::DummyClient.new(development_mode: true, logger: Rails.logger)
  else
    GDSZendesk::Client.new(
      username: ENV.fetch("ZENDESK_USER", nil),
      token: ENV.fetch("ZENDESK_TOKEN", nil),
      logger: Rails.logger,
      url: "https://teachingregulationagency.zendesk.com/api/v2/",
    )
  end
