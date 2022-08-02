class HaveTrnController < ApplicationController
  layout "two_thirds"

  def new
    @have_trn_form = HaveTrnForm.new
  end
end
