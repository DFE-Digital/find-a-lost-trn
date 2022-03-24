# frozen_string_literal: true
module HostingEnvironment
  TEST_ENVIRONMENTS = %w[local test development].freeze
  PRODUCTION_URL = 'https://find-a-lost-trn.education.gov.uk/'

  def self.environment_name
    ENV.fetch('HOSTING_ENVIRONMENT_NAME', 'unknown-environment')
  end
end
