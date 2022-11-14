# frozen_string_literal: true
class IttProvidersController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
    @itt_provider_options = fetch_itt_provider_options if FeatureFlag.active?(
      :use_dqt_api_itt_providers,
    )

    @itt_provider_form = IttProviderForm.new(trn_request:).assign_form_values
  end

  def update
    @itt_provider_form = IttProviderForm.new(itt_provider_params)
    if @itt_provider_form.save
      reset_and_attempt_to_find_a_trn
      next_question
    else
      if FeatureFlag.active?(:use_dqt_api_itt_providers)
        @itt_provider_options = fetch_itt_provider_options
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

  def fetch_itt_provider_options
    @fetch_itt_provider_options ||= IttProviderForm.itt_providers
  end
end
