# frozen_string_literal: true
class IttProvidersController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
    set_itt_provider_options if FeatureFlag.active?(:use_dqt_api_itt_providers)

    @itt_provider_form = IttProviderForm.new(trn_request:).assign_form_values
  end

  def update
    @itt_provider_form = IttProviderForm.new(itt_provider_params)
    if @itt_provider_form.save
      next_question
    else
      if FeatureFlag.active?(:use_dqt_api_itt_providers)
        set_itt_provider_options
      end
      render :edit
    end
  end

  private

  def itt_provider_params
    params
      .require(:itt_provider_form)
      .permit(:itt_provider_enrolled, :itt_provider_name)
      .merge(trn_request:)
  end

  def set_itt_provider_options
    @itt_provider_options ||=
      Rails
        .cache
        .fetch("itt_provider_options", expires_in: 1.hour) do
          DqtApi.get_itt_providers.map do |itt_provider|
            OpenStruct.new(
              name: itt_provider["providerName"],
              value: itt_provider["ukprn"]
            )
          end
        end
  rescue DqtApi::ApiError, Faraday::ConnectionFailed, Faraday::TimeoutError
    @itt_provider_options ||= []
  end
end
