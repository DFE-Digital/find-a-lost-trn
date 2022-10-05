class Staff::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def identity
    auth = request.env["omniauth.auth"]
    @staff = Staff.from_identity(auth)
    sign_in @staff
    session[:identity_users_api_access_token] = auth.credentials.token
    flash[:notice] = "Signed in successfully."
    redirect_to support_interface_path
  end
end
