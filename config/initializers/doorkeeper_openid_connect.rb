# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer 'https://dev-find-a-lost-trn.education.gov.uk/'

  signing_key <<~KEY
    -----BEGIN PRIVATE KEY-----
    MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCvm+EQvZfmgusD
    b9toQbxcy+i6cjILSFENMnTPwdBy3zwKwbr921WnD80PiC5nls+9Ue240ma3WeK+
    V0PjSd4xjKAg567wwxBkVxiW2ERcQ8ENL3PbhHCwFZg6IAs9IXKljsNyV3D9hpqH
    kiiAvfdsVS/Jk7ar3tOrtSuxgPTLLuvjZsWJLGw5zNGqD7mtM4MQcIBlcpG7zwj9
    zbKV/X9pjzIATabDrb9BbE84e3wZzmq22njS/7lwdhowO/++wf660FSBi2z4DzmH
    ryC1tG8SgVIawh2cKFPqrUyL+dfXMSrJve0aEKKUabQ8U1qB4WLBrxhAk19jjJHx
    uK6BxdtjAgMBAAECggEBAKFWclHCDnPOpgJTW14OvvL2uEvLrOSmvSiFycIyi8Nu
    CyjK0nR2ddv17W0urYuoiBWk1uYuEAa2A1bir9F7RTN6wodYtGYooL+/MS0tZqjp
    6sylYyk0JZ/xRxln5Ut1lnI6lqBPa9TRPNn/U0zsuwwBu9TT7Ek9gHVKDumW09Bz
    NW5/GlVFUqYZuu8e34cNmOn0hr39YWmtVHYAVJ7H2utADpT8KNjfzU5OBdSt5yyi
    yGUeE4VE519ZI7xcyHJqQCLi6WSWIsyZoK3iUpg0khzGfGrYMnYpvrj9gPaqx3f8
    I8iED3tECgOBpgrlfME1FVIPgkp/fInvGHeDTDzJPKECgYEA5s7IjGLAAZqXHFr/
    h8vr0WmU5RormygyaIbugAgapiWmnMLHN7MSztWXTRrfVE/cG9cKjSWuPLIQF0r+
    nN8D8jXeK6gc08cwtaALyHWouABQrc2Kyp0pHzZZ9ZHzyjgAEK7nxGmzh3zZ1l/W
    DBQomLP6uigrk5MOeKtOEQjWrPECgYEAwsa7nbbdPYbD3CPwXjVs2qT8NtyytVv7
    xWbeikIVpBWZVOuTDbwF6nBIPwS7/RdBcN39jklhRFS3NuZ6pU95d2X56vJOerP1
    49aeUkhkJBRM8dSKlHmnW4CeljheHTjuZL/YpW24WLBFsoiz820bJFaMx0HZDZy3
    fJaZvgB9XZMCgYEAnB/mIqgtrygN7X1UelwjQP1FXY/NTV/scS5MqEhTFm5DfKh4
    r6GvKD/s35g810BJ6H8WwRFrAd2E6uysvBpTBgUQKsHF9i84MLN5JPkJzqVP7bEq
    oBGdHmLaiTVYDkLBMIfPeNnzOcPnao5bMMJ2D403HbNMfr+ru05NOVKcPFECgYBO
    ybDu1R+dWbw0el0q3pWPxBk54AByGCk56qiuaJj0bMA/d6NedOY3tP+kbjfU4ulX
    zJRaUBiGWXZbQNPvtrw9rgRwI1/XhqA6b4BPbHUFmyic0grUkHlALED6Jwb67yKP
    ooLyN/XP+k3XMDEKkOHfyxrbJymztecLAKhkETKk/QKBgQCg9pzM/Tkovm3Uokqq
    HrPn0L4IjRInEQk/VEizQtgj7nCVQSb/57R6Colt4S/hfrAYKxPjdD9A2zlVeV3N
    WMFF09K5aciyHJYgoXeidwOAofpbuDgfRkNrtJCYVk6RwcY1FfLQFGLk1BenNW4g
    WQupXkNNu9trmWGtYFNVvcLkXQ==
    -----END PRIVATE KEY-----
  KEY

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    # Example implementation:
    # User.find_by(id: access_token.resource_owner_id)
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

  subject do |resource_owner, application|
    # Example implementation:
    # resource_owner.id

    # or if you need pairwise subject identifier, implement like below:
    # Digest::SHA256.hexdigest("#{resource_owner.id}#{URI.parse(application.redirect_uri).host}#{'your_secret_salt'}")
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Example claims:
  # claims do
  #   normal_claim :_foo_ do |resource_owner|
  #     resource_owner.foo
  #   end

  #   normal_claim :_bar_ do |resource_owner|
  #     resource_owner.bar
  #   end
  # end
end
