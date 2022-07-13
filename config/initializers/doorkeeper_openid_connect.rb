# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer "http://localhost:3001"

  signing_key <<~KEY
    -----BEGIN RSA PRIVATE KEY-----
    MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDEs3/3wtgCdSGo
    NB4NDR7OAaeGT0KbaKuBzDjnQM7lpUehWl4x7L8ZX8HzbTzE3wm4wZTjcFD1TBOY
    n/W3AUpWvyO3zJScOxFJNSRVDzrH0BamZpv6Dv1W7Ma0QWDEwipgI/JqiP9faD/G
    tk6w7pAdNIoSR3qXrKfLYWJRl/YRTKEo94zkEdnoYtmzaPyeD+hXBgEJlCedQBD3
    vWgX3flnfMJx+bZiT4RB3FQzAE8GGt97sh+t2RvqowCYNuWurSHMFGz1zdP6G/Pp
    lCjYnicIhh8390o0GfahHYJBSVZH2+iHz5gb4yklUy1wUrFSAuztJsx9KSzw+eKg
    yJn20wLhAgMBAAECggEAdZNuHKUlBWMKeUad5+M91Jn8jzX1dHu+eNmf8es1QOPo
    yzP/NgxztjEc9+sF9g/z+bIM016hpd6RoBuNfpSQ4QVjzkvFURWloYLYctelpSZn
    Q5P2DCTFnh3uMHUb6MC/H7SdBL1bGKZx6M+0feI71pk/Jun/B4a2zcUqRed1uKRu
    I5uczV9rcOg7YB/w3QGu5gIKvmOO99w7glSr9pbTT/7L+7NM+xKwdEpWjQ5NrWuT
    m8zCQdluPjiKdUM2XH7W9x4q1Y/RibCe0e009BGkUVQVQb/Bymb+/H1Woe89OPr/
    orM8F2ZqLjmyflLCtQ7laRTnfvknLdOwtOjlKwc/IQKBgQD1Sfy0JO/PntuE9an5
    I2WKyW0O3RkfPkMRXMY/tK9+D51iqSICjYpWs4HwKZCriYqVARBvyqqqALYaeejk
    7N5kdnBnIxBj/U+3veyg7O9Y5ftqBP+GapeEalVRGcdsThuQjOChvzgHAUo0LIyA
    maJsOnCLWYrr5yr2FHBNBjKyNQKBgQDNSl0d09+ZwNiITLIvgWSV/a2/k88nnKTp
    V/fPMLNTKTmzSOtNh9fOPnb4GLjnVY4MnDgEP+a62JbvC+DYfZncwTzcxb6HM+zy
    Fjg4041KnoveASAuDrJJNDszIfQfy8Ufi990zx5Ez54OqPdW5ghej0cDR7aGGzYy
    5kgN3XnjfQJ/Y6WrA4P96Fqg02L5qjy3A6rQozku+4JPvL3zy+2bXZr6VRpgtqjJ
    im9iWi6IlydJJT9JbiDnNCkV0au08UtJDYcQItYb0oMV349IkhevJG5JtMhTBkhH
    RYPtJQVT/qu8hvy0RQFpwW7Etm1iptvDIDSdg/7ccPl4en/TH3dlIQKBgQDIKaW5
    G4h9Rcbavs1N/H+yr3HlxZzKJrW0vwzke7udbijQYlzrb3Q/qDAfnxtKk+S47ui/
    W/8AV4Zy9cX50B1hXRiWukgXU83IDVosLjkpdIUzpS1XOwUi00aViJmbFvfQ1nS+
    U+RTe4vFB4KCvC+U42Z+EEIraATkhBvlSPk7kQKBgQC7LQSguq3wxdKfGDshYO2d
    vB2My9xEjnxs1M2JwmLS3S5M1noiQJJj+05Y83hrlT7qkFd97Je2WBzWPVn3kX5a
    K3CicfbHKX42hTNHqLym/5xVLxe1OLuKil2OaGnN5GHYkfezhJwo3q+90ylqg5qD
    nA2PJC9PiqaqgF3PFqGh9A==
    -----END RSA PRIVATE KEY-----
  KEY

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    User.find_by(id: access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    # resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  # Depending on your configuration, a DoubleRenderError could be raised
  # if render/redirect_to is called at some point before this callback is executed.
  # To avoid the DoubleRenderError, you could add these two lines at the beginning
  #  of this callback: (Reference: https://github.com/rails/rails/issues/25106)
  #   self.response_body = nil
  #   @_response_body = nil
  select_account_for_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # redirect_to account_select_url
  end

  subject { |resource_owner| resource_owner.id }

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  claims { normal_claim :_email, &:email }
end
