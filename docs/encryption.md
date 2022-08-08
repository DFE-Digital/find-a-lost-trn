# Encryption

The application uses [ActiveRecord Encryption](https://guides.rubyonrails.org/active_record_encryption.html) to encrypt sensitive data.

Application-level encryption ensures that we reduce the risk of leaking PII information should
the database ever be compromised.

## Encryption keys

Rails encrypts data using a key that is stored outside of version control. In deployed environments
we use the RAILS_MASTER_KEY environment variable to pass the key to the application.

For local development, the key is stored in `config/master.key`. This file is not encrypted, so it
should be kept secret.

### Accessing the key

To gain access to this key, you can call `make dev print-keyvault-secret | grep RAILS_MASTER_KEY` and
then copy the value from the output to your local `config/master.key` file.

### Rotating keys

There may be a reason to rotate the encryption key in the future. See [this guide](https://guides.rubyonrails.org/active_record_encryption.html#rotating-keys) for the details.

ActiveRecord Encryption supports a list of keys. It uses the last key in the list for encrypting data
and will try all the keys in the list for decrypting until one works.

To add a new key to the list, make sure you have the correct value set in `config/master.key`. Then...

```bash
bin/rails credentials:edit
```

Add a new key to the list and then save the file. This will mutate the `config/credentials.yml.enc` file.
Commit these changes to the repo and deploy.
