# frozen_string_literal: true
module HostingEnvironment
  TEST_ENVIRONMENTS = %w[local test development review].freeze
  PRODUCTION_URL = "https://find-a-lost-trn.education.gov.uk/"

  def self.host
    ENV.fetch("HOSTING_DOMAIN")
  end

  def self.environment_name
    ENV.fetch("HOSTING_ENVIRONMENT_NAME", "unknown-environment")
  end

  def self.test_environment?
    TEST_ENVIRONMENTS.include?(HostingEnvironment.environment_name)
  end

  def self.production?
    environment_name == "production"
  end
end
