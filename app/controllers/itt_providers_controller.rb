# frozen_string_literal: true
class IttProvidersController < ApplicationController
  include EnforceQuestionOrder

  def edit
    @itt_provider_form = IttProviderForm.new(trn_request: trn_request).assign_form_values
  end

  def update
    @itt_provider_form = IttProviderForm.new(itt_provider_params)
    if @itt_provider_form.save
      redirect_to trn_request.email.blank? ? email_url : check_answers_url
    else
      render :edit
    end
  end

  private

  def itt_provider_params
    params
      .require(:itt_provider_form)
      .permit(:itt_provider_enrolled, :itt_provider_name)
      .merge(trn_request: trn_request)
  end
end
