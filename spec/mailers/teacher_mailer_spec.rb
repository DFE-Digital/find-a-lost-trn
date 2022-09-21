# frozen_string_literal: true
require "rails_helper"

RSpec.shared_examples "a mail with subject and content" do |email_subject, content|
  it "sends an email with the correct subject and #{content.keys.to_sentence} in the body" do
    expect(email.subject).to eq(email_subject)

    content.each do |_, expectation|
      if expectation.is_a?(Regexp)
        expect(email.body).to match(expectation)
      else
        expectation = expectation.call if expectation.respond_to?(:call)
        expect(email.body).to include(expectation)
      end
    end
  end
end

RSpec.describe TeacherMailer, type: :mailer do
  let(:trn_request) do
    TrnRequest.new(
      first_name: "Joe",
      last_name: "Bloggs",
      email: "joe@example.com",
      trn: 1_234_567,
    )
  end

  describe ".found_trn" do
    let(:email) { described_class.found_trn(trn_request) }

    it_behaves_like(
      "a mail with subject and content",
      "Your TRN is 1234567",
      "content" => "We suggest you keep this email for future reference",
    )
  end
end
