# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Performance", type: :system do
  before { Timecop.freeze(Date.new(2022, 5, 12)) }

  after { Timecop.return }

  it "using the performance dashboard" do
    given_the_service_is_open
    given_there_are_a_few_trns
    when_i_visit_the_performance_page
    then_i_see_the_live_stats
    and_i_see_the_usage_duration
    and_i_see_journeys_through_the_service
  end

  private

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_there_are_a_few_trns
    (0..8).each.with_index do |n, i|
      (i + 1).times do
        create(
          :trn_request,
          :has_trn,
          created_at: n.days.ago,
          checked_at: n.days.ago + 3.minutes,
          has_ni_number: true,
          awarded_qts: nil
        )
      end
    end
  end

  def when_i_visit_the_performance_page
    visit performance_path
  end

  def then_i_see_the_live_stats
    expect(page).to have_content("36\nrequests today and the previous 7 days")
    expect(page).to have_content("12 May\t1")
    expect(page).to have_content("6 May\t7")
  end

  def and_i_see_the_usage_duration
    expect(page).to have_content("12 May\t3 minutes\t3 minutes\t3 minutes")
    expect(page).to have_content("6 May\t3 minutes\t3 minutes\t3 minutes")
    expect(page).to have_content(
      "Average (today and the last 7 days)\t3 minutes\t3 minutes\t3 minutes"
    )
  end

  def and_i_see_journeys_through_the_service
    expect(page).to have_content(
      "4 questions\n+ National Insurance number\t36 users (100%)"
    )
  end
end
