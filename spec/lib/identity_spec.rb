require "rails_helper"

RSpec.describe Identity do
  describe "#signature_from" do
    it "computes a SHA256 HMAC signature from a set of params" do
      sig = described_class.signature_from({ foo: "bar" })
      expect(sig).to eq(
        "e037a467e455d7847d50df4a6fa3b1c2ebfa4234b19cb7b2a220f1ffbfe9fdb8"
      )
    end
  end

  describe "#encode_params" do
    it "encodes params" do
      encoded_params = described_class.encode_params({ foo: "bar" })
      expect(encoded_params).to eq("foo=bar")
    end
  end
end
