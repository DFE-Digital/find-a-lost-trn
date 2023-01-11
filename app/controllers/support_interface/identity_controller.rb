module SupportInterface
  class IdentityController < SupportInterfaceController
    def new
      @identity_params = IdentityParamsForm.new
      @identity_params.client_title =
        "Register for a National Professional Qualification"
      @identity_params.client_id = "register-for-npq"
      @identity_params.client_url = client_url
      @identity_params.email = "kevin.e@example.com"
      @identity_params.journey_id = journey_id
      @identity_params.previous_url = previous_url
      @identity_params.redirect_url = redirect_url
      @identity_params.session_id = SecureRandom.uuid
    end

    def confirm
      @identity_params = {
        client_title: create_params[:client_title],
        client_id: create_params[:client_id],
        client_url:,
        email: create_params[:email],
        journey_id:,
        previous_url:,
        redirect_url:,
        session_id: create_params[:session_id],
      }
      sig = Identity.signature_from(@identity_params)
      @identity_params[:sig] = sig
    end

    def callback
      flash[
        :success
      ] = "You have completed a simulated Identity journey with session ID #{params[:session_id]}"

      redirect_to support_interface_identity_simulate_path
    end

    private

    def create_params
      params.require(:support_interface_identity_params_form).permit(
        :client_title,
        :client_id,
        :email,
        :session_id,
      )
    end

    def journey_id
      "9ddccb62-ec13-4ea7-a163-c058a19b8222"
    end

    def redirect_url
      support_interface_identity_simulate_callback_path
    end

    def client_url
      support_interface_identity_simulate_callback_path
    end

    def previous_url
      support_interface_identity_simulate_path
    end
  end
end
