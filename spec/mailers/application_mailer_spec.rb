require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe ".notify_email" do
    subject(:notify_email) { described_class.notify_email(headers) }

    let(:headers) { {} }

    before do
      ActionMailer::Base.add_delivery_method(
        :notify,
        Mail::Notify::DeliveryMethod
      )
      ActionMailer::Base.delivery_method = :notify
      ActionMailer::Base.notify_settings = { api_key: }
    end

    context "when the API key is blank" do
      let(:api_key) { "" }

      it "raises an error" do
        expect { notify_email.deliver! }.to raise_error(
          ArgumentError,
          "You must specify an API key"
        )
      end
    end
  end
end
