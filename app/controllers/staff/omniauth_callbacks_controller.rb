class Staff::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def identity
    auth = request.env["omniauth.auth"]
    @staff = Staff.from_identity(auth)
    sign_in @staff
    session[:identity_users_api_access_token] = auth.credentials.token
    flash[:notice] = "Signed in successfully."
    redirect_to support_interface_path
  rescue Staff::IdentityEmailConflictError => e
    Sentry.capture_exception(e, contexts: { identity: { uid: e.uid, existing_staff_uid: e.existing_staff_uid } })
    redirect_to_sign_in_with_alert("your email address is already linked to a different sign-in")
  rescue Staff::IdentityMissingUidError => e
    Sentry.capture_exception(e)
    redirect_to_sign_in_with_alert("of a problem with the sign-in service")
  end

  private

  def redirect_to_sign_in_with_alert(reason)
    flash[:alert] =
      "We could not sign you in because #{reason}. Contact the " \
      "#{t('service.name')} team at #{t('service.email')} for help."
    redirect_to new_staff_session_path
  end
end
