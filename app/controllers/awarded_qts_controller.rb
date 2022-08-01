class AwardedQtsController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
    @awarded_qts_form = AwardedQtsForm.new(trn_request:)
  end

  def update
    @awarded_qts_form = AwardedQtsForm.new(trn_request:)
    if @awarded_qts_form.update(awarded_qts_params)
      next_question
    else
      render :edit
    end
  end

  private

  def awarded_qts_params
    params.require(:awarded_qts_form).permit(:awarded_qts)
  end
end
