# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Zendesk ticket syncing", type: :system do
  before do
    given_the_service_is_open
    given_the_zendesk_integration_feature_is_enabled
  end

  after { deactivate_feature_flags }

  context "when the ticket has a TRN" do
    it "checks the ticket at regular intervals", vcr: true do
      given_there_is_a_completed_trn_request
      and_i_am_on_the_check_answers_page
      freeze_time do
        when_i_press_the_submit_button
        then_a_job_to_check_zendesk_is_queued
      end

      travel 2.days do
        perform_enqueued_jobs
        then_a_job_to_check_zendesk_is_not_queued
      end
    end
  end

  context "when the ticket has no TRN in the comments" do
    let(:ticket_with_no_trn) do
      ZendeskAPI::Ticket
        .new(GDS_ZENDESK_CLIENT, id: 1)
        .tap do |ticket|
          ticket.comments = [
            ZendeskAPI::Ticket::Comment.new(
              GDS_ZENDESK_CLIENT,
              id: 1,
              body: "Example"
            ),
            ZendeskAPI::Ticket::Comment.new(
              GDS_ZENDESK_CLIENT,
              id: 2,
              body: "Thanks"
            )
          ]
        end
    end

    before do
      allow(GDS_ZENDESK_CLIENT.ticket).to receive(:find).and_return(
        ticket_with_no_trn
      )
    end

    it "checks the ticket at regular intervals", vcr: true do
      given_there_is_a_completed_trn_request
      and_i_am_on_the_check_answers_page
      freeze_time do
        when_i_press_the_submit_button
        then_a_job_to_check_zendesk_is_queued
      end

      travel 2.days do
        perform_enqueued_jobs
        then_a_job_to_check_zendesk_tomorrow_is_queued
      end

      when_the_ticket_is_closed
      travel 3.days do
        perform_enqueued_jobs
        then_a_job_to_check_zendesk_is_not_queued
      end
    end
  end

  private

  def and_i_am_on_the_check_answers_page
    visit trn_request_path
  end

  def deactivate_feature_flags
    FeatureFlag.deactivate(:service_open)
    FeatureFlag.deactivate(:zendesk_integration)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_the_zendesk_integration_feature_is_enabled
    FeatureFlag.activate(:zendesk_integration)
  end

  def given_there_is_a_completed_trn_request
    visit root_path
    click_on "Start now"
    choose "Yes", visible: false
    click_on "Continue"
    click_on "Continue"

    fill_in "Your email address", with: "kevin@kevin.com"
    click_on "Continue"

    fill_in "First name", with: "Not"
    fill_in "Last name", with: "Valid"
    choose "No, I’ve not changed my name", visible: false
    click_on "Continue"

    fill_in "Day", with: "01"
    fill_in "Month", with: "01"
    fill_in "Year", with: "1990"
    click_on "Continue"

    choose "No", visible: false
    click_on "Continue"

    choose "No", visible: false
    click_on "Continue"
  end

  def then_a_job_to_check_zendesk_is_queued
    expect(CheckZendeskTicketForTrnJob).to have_been_enqueued.at(
      2.days.from_now
    ).with(TrnRequest.last.id)
  end

  def then_a_job_to_check_zendesk_tomorrow_is_queued
    expect(CheckZendeskTicketForTrnJob).to have_been_enqueued.at(
      1.day.from_now
    ).with(TrnRequest.last.id)
  end

  def then_a_job_to_check_zendesk_is_not_queued
    expect(CheckZendeskTicketForTrnJob).not_to have_been_enqueued
  end

  def when_i_press_the_submit_button
    click_on "Submit"
  end

  def when_the_ticket_is_closed
    ticket_with_no_trn.status = "closed"
  end
end
