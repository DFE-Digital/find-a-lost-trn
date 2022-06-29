# frozen_string_literal: true
class IttProvidersController < ApplicationController
  include EnforceQuestionOrder

  def new
    @awarded_qts_form = AwardedQtsForm.new(trn_request:)
  end

  def create
    @awarded_qts_form = AwardedQtsForm.new(trn_request:)
    if @awarded_qts_form.update(awarded_qts_params)
      next_url =
        if trn_request.reload.awarded_qts
          itt_provider_url
        else
          trn_request.email.blank? ? email_url : check_answers_url
        end
      redirect_to next_url
    else
      render :new
    end
  end

  def edit
    @itt_provider_form = IttProviderForm.new(trn_request:).assign_form_values
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

  def awarded_qts_params
    params.require(:awarded_qts_form).permit(:awarded_qts)
  end

  def itt_provider_params
    params
      .require(:itt_provider_form)
      .permit(:itt_provider_enrolled, :itt_provider_name)
      .merge(trn_request:)
  end
end
