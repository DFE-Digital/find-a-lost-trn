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

    when_i_visit_the_performance_page_since_launch
    then_i_see_the_live_stats_since_launch
    and_i_see_the_usage_duration_since_launch
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
          checked_at: n.days.ago + 3.minutes
        )
      end
    end
  end

  def when_i_visit_the_performance_page
    visit performance_path
  end

  def then_i_see_the_live_stats
    expect(page).to have_content("36\nrequests over the last 7 days")
    expect(page).to have_content("12 May\t1")
    expect(page).to have_content("06 May\t7")
  end

  def and_i_see_the_usage_duration
    expect(page).to have_content("12 May\t3 minutes\t3 minutes\t3 minutes")
    expect(page).to have_content("06 May\t3 minutes\t3 minutes\t3 minutes")
    expect(page).to have_content(
      "Average over the last 7 days\t3 minutes\t3 minutes\t3 minutes"
    )
  end

  def when_i_visit_the_performance_page_since_launch
    visit performance_path(since_launch: true)
  end

  def then_i_see_the_live_stats_since_launch
    expect(page).to have_content("45\nrequests since launch")
    expect(page).to have_content("12 May\t1")
    expect(page).to have_content("04 May\t9")
  end

  def and_i_see_the_usage_duration_since_launch
    expect(page).to have_content("12 May\t3 minutes\t3 minutes\t3 minutes")
    expect(page).to have_content("04 May\t3 minutes\t3 minutes\t3 minutes")
    expect(page).to have_content(
      "Average since launch\t3 minutes\t3 minutes\t3 minutes"
    )
  end
end
