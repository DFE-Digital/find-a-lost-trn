# 8. Encrypt database fields

Date: 2022-08-04

## Status

Accepted

## Context

Currently, the database isn't encrypted at the application level and any leak of data
could expose PII.

We want to encrypt the PII fields to lessen the impact of any breach of the
database.

Rails 7 introduced [encryption](https://edgeguides.rubyonrails.org/active_record_encryption.html) as a feature. It seamlessly encrypts the data
on write and decrypts it on read provided you have the master key.

This means that we can encrypt the PII fields in the database without any change to the
way we use and display the data.

## Decision

We will use ActiveRecord Encryption to encrypt the PII fields on a per-model basis.

## Consequences

All environments will require access to the master key to be able to decrypt the PII fields.

See the `docs/encryption.md` for details on managing the keys.
