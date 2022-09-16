# frozen_string_literal: true
class DqtApi
  class ApiError < StandardError
  end

  class TooManyResults < StandardError
  end

  class NoResults < StandardError
  end

  FIVE_SECONDS = 5

  def self.find_trn!(trn_request)
    if FeatureFlag.active?(:dqt_api_always_timeout)
      raise Faraday::TimeoutError, "Time-out feature flag enabled"
    end

    response =
      new.client.get("/v2/teachers/find", trn_request_params(trn_request))
    raise ApiError, response.reason_phrase unless response.status == 200

    results = response.body["results"]
    raise TooManyResults if results.size > 1

    raise NoResults if results.size.zero?

    teacher_account = results.first

    unless trn_request.previous_trn_success_for_email?
      UnlockTeacherAccountJob.perform_later(uid: teacher_account.fetch("uid"))
    end

    teacher_account
  end

  def self.find_teacher!(date_of_birth:, trn:)
    response =
      new.client.get("/v1/teachers/#{trn}", { birthdate: date_of_birth })
    response.body
  end

  def self.get_itt_providers
    response = new.client.get("/v2/itt-providers", {})
    raise ApiError unless response.status == 200

    return [] unless response.body.key?("ittProviders")
    response.body["ittProviders"]
  end

  def self.unlock_teacher!(uid:)
    if FeatureFlag.active?(:unlock_teachers_self_service_portal_account)
      begin
        response = new.client.put("/v2/unlock-teacher/#{uid}", {})
        raise ApiError, response.reason_phrase unless response.success?
        response.body['hasBeenUnlocked']
      rescue ApiError => e
        Sentry.capture_exception(e)
        nil
      end
    end
  end

  def self.trn_request_params(trn_request)
    {
      dateOfBirth: trn_request.date_of_birth,
      emailAddress: trn_request.email,
      firstName: trn_request.first_name,
      ittProviderName: trn_request.itt_provider_name_for_dqt,
      ittProviderUkprn: trn_request.itt_provider_ukprn,
      lastName: trn_request.last_name,
      previousFirstName: trn_request.previous_first_name,
      previousLastName: trn_request.previous_last_name,
      nationalInsuranceNumber: trn_request.ni_number,
      trn: trn_request.trn_from_user
    }.compact
  end

  def client
    @client ||=
      Faraday.new(
        url: ENV.fetch("DQT_API_URL", nil),
        request: {
          timeout: FIVE_SECONDS
        }
      ) do |faraday|
        faraday.request :authorization, "Bearer", ENV.fetch("DQT_API_KEY", nil)
        faraday.request :json
        faraday.response :json
        faraday.response :logger,
                         nil,
                         { bodies: true, headers: true } do |logger|
          logger.filter(
            /((emailAddress|firstName|lastName|nationalInsuranceNumber|previousFirstName|previousLastName)=)([^&]+)/,
            '\1[REDACTED]'
          )
        end
        faraday.adapter Faraday.default_adapter
      end
  end
end
