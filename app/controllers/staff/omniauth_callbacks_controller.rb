class Staff::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def identity
    @staff = Staff.from_identity(request.env["omniauth.auth"])
    sign_in @staff
    flash[:notice] = "Signed in successfully."
    redirect_to support_interface_path
  end
end
