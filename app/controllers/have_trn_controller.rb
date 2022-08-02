class HaveTrnController < ApplicationController
  layout "two_thirds"

  def new
    @have_trn_form = HaveTrnForm.new
  end

  def create
    @have_trn_form = HaveTrnForm.new(have_trn_params)
    if @have_trn_form.valid?
      redirect_to(
        (@have_trn_form.trn? ? know_trn_path : you_dont_have_a_trn_path)
      )
    else
      render :new
    end
  end

  private

  def have_trn_params
    params.require(:have_trn_form).permit(:has_trn)
  end
end
