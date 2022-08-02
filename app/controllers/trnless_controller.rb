class TrnlessController < ApplicationController
  layout "two_thirds"

  def new
    @trnless_form = TrnlessForm.new
  end
end
