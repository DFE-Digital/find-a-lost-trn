module SupportInterface
  class IdentityController < SupportInterfaceController
    def new
      @identity_params = IdentityParamsForm.new
      @identity_params.client_title =
        "Register for a National Professional Qualification"
      @identity_params.email = "kevin.e@example.com"
      @identity_params.journey_id = journey_id
      @identity_params.redirect_uri = redirect_uri
    end

    def confirm
      @identity_params = {
        client_title: create_params[:client_title],
        email: create_params[:email],
        journey_id:,
        redirect_uri:
      }
      sig = Identity.signature_from(@identity_params)
      @identity_params[:sig] = sig
    end

    def callback
      flash[:success] = "You have completed a simulated Identity journey"

      redirect_to support_interface_identity_path
    end

    private

    def create_params
      params.require(:support_interface_identity_params_form).permit(
        :client_title,
        :email
      )
    end

    def journey_id
      "9ddccb62-ec13-4ea7-a163-c058a19b8222"
    end

    def redirect_uri
      support_interface_identity_callback_path
    end
  end
end