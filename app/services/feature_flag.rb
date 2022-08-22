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
    [
      :slack_alerts,
      "Enable Slack alerts and notifications for this environment",
      "Felix Clack"
    ],
    [
      :staff_http_basic_auth,
      "Allow signing in as a staff user using HTTP Basic authentication. " \
        "This is useful before staff users have been created, but should " \
        "otherwise be inactive.",
      "Theodor Vararu"
    ]
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [
      :identity_api_always_timeout,
      "Always time-out the Identity API",
      "Richard da Silva"
    ],
    [
      :identity_open,
      "Allow access to the get an identity endpoint",
      "Richard da Silva"
    ],
    [
      :use_dqt_api_itt_providers,
      "Use autocomplete from DQT API results",
      "Richard da Silva"
    ],
    [:dqt_api_always_timeout, "Always time-out the DQT API", "Felix Clack"],
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
    [
      :unlock_teachers_self_service_portal_account,
      "Unlock a teacher's self service portal account if their TRN is found",
      "Ransom Voke Anighoro"
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
