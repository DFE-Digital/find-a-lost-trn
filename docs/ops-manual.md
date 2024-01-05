# Find a lost TRN ops manual

## SSHing to a live docker container

To SSH into a container, install `kubectl`

- Configure the credentials using the `get-cluster-credentials`, run make command. Example:

```
make test get-cluster-credentials
make development get-cluster-credentials ENVIRONMENT=cluster1
```

find-a-lost-trn-test-57556754f9-q5mfd
To SSH into a container, in the test cluster. Example ssh into a container named `find-a-lost-trn-test`, within the pod `find-a-lost-trn-test-57556754f9-q5mfd`:

run `kubectl -n tra-test exec -it find-a-lost-trn-test-57556754f9-q5mfd -c find-a-lost-trn-test -- /bin/sh`

## Running a Rails console

SSH into the machine and run:

```bash
/usr/local/bin/bundle exec rails console
```

## Tailing logs

SSH into the machine and run:

```bash
tail -f /app/log/production.log
```

## Updating environment variables

Make sure you have the `az` command line tool:

```bash
asdf plugin add azure-cli

asdf install
```

Login to Azure and make sure it gets the right subscriptions:

```bash
$ az login
A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no
web browser is available or if the web browser fails to open, use device code
flow with `az login --use-device-code`.
The following tenants don't contain accessible subscriptions. Use 'az login --allow-no-subscriptions' to have tenant level access.
xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy 'digital.education.gov.uk'
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy",
    "id": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy",
    "isDefault": true,
    "managedByTenants": [
      {
        "tenantId": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy"
      }
    ],
    "name": "s189-teacher-services-cloud-test",
    "state": "Enabled",
    "tenantId": "xxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy",
    "user": {
      "name": "Joe.BLOGGS@digital.EDUCATION.GOV.UK",
      "type": "user"
    }
  },
  ...
]
```

To view all environment variables on the `dev` environment:

```bash
make dev print-keyvault-secret
```

To edit environment variables on the `dev` environment (opens `$EDITOR`):

```bash
make dev edit-keyvault-secret
```

## Logit

You can raise a request to #digital-tools-support on Slack filling the [Digital Tools Request Form](https://docs.google.com/forms/d/e/1FAIpQLSe8pAACWb8FUH0qXpUsoUoa6w1GuRvSNour-lHliGPaJ7u73A/viewform) to be added to Teaching Regulation Agency (TRA) stack. Follow the **Logit** section of [the TRA resources Google document](https://docs.google.com/document/d/1A6TMWkFYc_q2IQLh5KhRSPOr91e_l9lxI_tFtZ8tdxc/edit#heading=h.8atf3at2he6o)document to help you fill the form. You can sign in once your email is added to the Logit stack.
