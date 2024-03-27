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

The app keyvaults for Find can be found in the Azure devops portal. The development one, for example, is found [here](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/20da9d12-7ee1-42bb-b969-3fe9112964a7/resourceGroups/s189t01-faltrn-dv-rg/providers/Microsoft.KeyVault/vaults/s189t01-faltrn-dv-app-kv/secrets).

Assuming you have the correct permissions, the environment variables can be edited via the portal UI. Check with the infrastructure team if you don't have access.

## Logit

You can raise a request to #digital-tools-support on Slack filling the [Digital Tools Request Form](https://docs.google.com/forms/d/e/1FAIpQLSe8pAACWb8FUH0qXpUsoUoa6w1GuRvSNour-lHliGPaJ7u73A/viewform) to be added to Teaching Regulation Agency (TRA) stack. Follow the **Logit** section of [the TRA resources Google document](https://docs.google.com/document/d/1A6TMWkFYc_q2IQLh5KhRSPOr91e_l9lxI_tFtZ8tdxc/edit#heading=h.8atf3at2he6o)document to help you fill the form. You can sign in once your email is added to the Logit stack.
