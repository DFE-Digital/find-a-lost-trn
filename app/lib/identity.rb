class Identity
  def self.signature_from(params)
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new("sha256"),
      ENV["IDENTITY_SHARED_SECRET_KEY"],
      encode_params(params),
    )
  end

  # Encode each of the hash values and return a url parameter string.
  # url_encode ensures spaces are encoded as '%20' rather than '+' to match the
  # encoding used by Identity.
  def self.encode_params(params)
    sorted_params = params.sort # Keys must be in alphabetical order.

    encoded_params =
      sorted_params.flat_map do |k, v|
        encoded_value = ERB::Util.url_encode(v)
        "#{k}=#{encoded_value}"
      end

    encoded_params.join("&")
  end
end
