# Staff Authentication

There are two authentication mechanisms available when accessing `/support`.

## Basic auth

If no Staff users exist, it's possible to sign in via the
StaffHttpBasicAuthStrategy. The username and password are set by the
SUPPORT_USERNAME/SUPPORT_PASSWORD env vars. Simply having these set will
provide access to the support interface.

Once Staff users are present in your database, this sign in mode can be
reenabled manually by activating the `staff_http_basic_auth` feature.

## Identity API

This mode uses an OpenID Connect auth flow that interacts with the Get an
Identity API. It relies on several things being in place for it to work on an
environment:

- Activate the `identity_auth_service` feature
- Set an IDENTITY_CLIENT_ID environment variable with value `get-an-identity-support`
- Set a valid IDENTITY_CLIENT_SECRET (ask a tech lead)
- Set IDENTITY_API_URL to https://preprod.teaching-identity.education.gov.uk
- Ask an Identity API team member to set up a user with your DfE email address
  on the Identity preprod environment

Following this, you can:

- Navigate to `/staff/sign_in`
- Click 'Sign in with Identity'
- Follow the Identity auth flow, which should redirect you back to the support interface

Note that if `staff_http_basic_auth` is active at the same time as
`identity_auth_service`, signing out functionality may appear to be broken.
This is merely the StaffHttpBasicAuthStrategy behaving as designed and
authenticating each request regardless of what's in the session.
