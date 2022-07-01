# frozen_string_literal: true
class FeatureFlag
  attr_accessor :name, :description, :owner

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
  end

  def feature
    Feature.find_or_initialize_by(name:)
  end

  PERMANENT_SETTINGS = [
    [:zendesk_health_check, "Check Zendesk health", "Felix Clack"]
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:dqt_api_always_timeout, "Always time-out the DQT API", "Felix Clack"],
    [:log_validation_errors, "Log validation errors", "Felix Clack"],
    [
      :processing_delays,
      "Show users banners and interstitials warning them of increased waiting times",
      "Felix Clack"
    ],
    [
      :service_open,
      "Allow users to access the service and submit TRN Requests",
      "Theodor Vararu"
    ],
    [:use_dqt_api, "Use DQT API to find TRN", "Felix Clack"],
    [
      :zendesk_integration,
      "Submit tickets to Zendesk on behalf of users at the end of the journey",
      "Theodor Vararu"
    ]
  ].freeze

  FEATURES =
    (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS)
      .to_h do |name, description, owner|
        [name, FeatureFlag.new(name:, description:, owner:)]
      end
      .with_indifferent_access
      .freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, true)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, false)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    feature_statuses[feature_name].presence || false
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active

    feature.save!
  end

  def self.feature_statuses
    Feature
      .where(name: FEATURES.keys)
      .pluck(:name, :active)
      .to_h
      .with_indifferent_access
  end
end
