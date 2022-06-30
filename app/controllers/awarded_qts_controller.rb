class AwardedQtsController < ApplicationController
  include EnforceQuestionOrder

  def edit
    @awarded_qts_form = AwardedQtsForm.new(trn_request:)
  end

  def update
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
      render :edit
    end
  end

  private

  def awarded_qts_params
    params.require(:awarded_qts_form).permit(:awarded_qts)
  end
end
