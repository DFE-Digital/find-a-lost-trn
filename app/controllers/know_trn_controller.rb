class KnowTrnController < ApplicationController
  layout "two_thirds"

  def new
    @know_trn_form = KnowTrnForm.new
  end

  def create
    @know_trn_form = KnowTrnForm.new(know_trn_params)
    if @know_trn_form.valid?
      redirect_to @know_trn_form.know_trn? ? enter_trn_path : start_path
    else
      render :new
    end
  end

  private

  def know_trn_params
    params.require(:know_trn_form).permit(:know_trn)
  end
end
