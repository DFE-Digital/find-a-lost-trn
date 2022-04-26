# Extending the Find a lost TRN service to become an identity provider

## Overview

The "Find a lost TRN" (FALTRN) service, as part of its function, gathers user information and attempts to furnish its users with a TRN by matching the supplied data against the DQT, using the DQT API.

Other teacher services would benefit from making this information portable, so that this user information can be shared.

## Proposed solution

Extending the functionality of the FALTRN service to be an OpenID Connect provider.

Other Teacher Services would register as relying parties with the FALTRN application, and would redirect users using the OIDC protocol.

The user would then either sign in (if they have used the service before and have already looked up their TRN), or go through the main process of FALTRN and find their TRN.

The information gathered during the process is stored against a local account, and makes up the claims that will be available to relying parties.

### Potential Problems

* What happens if a user is redirected to the FALTRN service, but the service cannot find a match? Redirect back to the caller with the OIDC compliant error mechanic? with a specific error?
* We'll most likely use a ruby gem to implement OIDC, but we will need to be able to customise its implementation, and this may not be supported by the gem.
    * We'll need to do our own claims transforms to insert the claims we want
    * We *may* need to override any consent screens to give a more "joined-up" experience
    * We'll need to support implicit flow, and code flow with PKCE (for clients who cant keep secrets private)
    * We'll need to support the OIDC Discovery metadata endpoint, so that when we rotate keys, clients can auto-configure.
    * Someone needs to rotate those keys I just mentioned
    * We need to handle client registration - if the gem supports OIDC dynamic registration, great - if not, its manual.
        * Maybe just support dynamic registration in prelive environments, to allow other services to test?
