.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dev:
	$(eval DEPLOY_ENV=dev)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)

test:
	$(eval DEPLOY_ENV=test)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)

preprod:
	$(eval DEPLOY_ENV=preprod)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)

production:
	$(eval DEPLOY_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-production)

read-keyvault-config:
	$(eval KEY_VAULT_NAME=$(shell jq -r '.key_vault_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval KEY_VAULT_SECRET_NAME=$(shell jq -r '.key_vault_secret_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))

read-deployment-config:
	$(eval SPACE=$(shell jq -r '.paas_space' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval POSTGRES_DATABASE_NAME=$(shell jq -r '.postgres_database_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval FLT_APP_NAME=$(shell jq -r '.flt_app_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))

set-azure-account: ${environment}
	echo "Logging on to ${AZURE_SUBSCRIPTION}"
	az account set -s ${AZURE_SUBSCRIPTION}

ci:	## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)

.PHONY: install-fetch-config
install-fetch-config: ## Install the fetch-config script, for viewing/editing secrets in Azure Key Vault
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

edit-infra-secrets: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

print-infra-secrets: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml

validate-infra-secrets: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -d quiet \
		&& echo Data in ${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} looks valid

.PHONY: set-space-developer
set-space-developer: read-deployment-config ## make dev set-space-developer USER_ID=first.last@digital.education.gov.uk
	$(if $(USER_ID), , $(error Missing environment variable "USER_ID", USER_ID required for this command to run))
	cf set-space-role ${USER_ID} dfe ${SPACE} SpaceDeveloper

.PHONY: unset-space-developer
unset-space-developer: read-deployment-config ## make dev unset-space-developer USER_ID=first.last@digital.education.gov.uk
	$(if $(USER_ID), , $(error Missing environment variable "USER_ID", USER_ID required for this command to run))
	cf unset-space-role ${USER_ID} dfe ${SPACE} SpaceDeveloper

stop-app: read-deployment-config ## Stops api app, make dev stop-app CONFIRM_STOP=1
	$(if $(CONFIRM_STOP), , $(error stop-app can only run with CONFIRM_STOP))
	cf target -s ${SPACE}
	cf stop ${FLT_APP_NAME}

get-postgres-instance-guid: read-deployment-config ## Gets the postgres service instance's guid
	cf target -s ${SPACE} > /dev/null
	cf service ${POSTGRES_DATABASE_NAME} --guid
	$(eval DB_INSTANCE_GUID=$(shell cf service ${POSTGRES_DATABASE_NAME} --guid))

rename-postgres-service: read-deployment-config ## make dev rename-postgres-service NEW_NAME_SUFFIX=old CONFIRM_RENAME
	$(if $(CONFIRM_RENAME), , $(error can only run with CONFIRM_RENAME))
	$(if $(NEW_NAME_SUFFIX), , $(error NEW_NAME_SUFFIX is required))
	cf target -s ${SPACE} > /dev/null
	cf rename-service  ${POSTGRES_DATABASE_NAME} ${POSTGRES_DATABASE_NAME}-$(NEW_NAME_SUFFIX)

remove-postgres-tf-state: terraform-init ## make dev remove-postgres-tf-state PASSCODE=XXX
	cd terraform && terraform state rm cloudfoundry_service_instance.postgres

restore-postgres: terraform-init read-deployment-config ## make dev restore-postgres DB_INSTANCE_GUID="<cf service db-name --guid>" BEFORE_TIME="yyyy-MM-dd hh:mm:ss" TF_VAR_api_docker_image=ghcr.io/dfe-digital/find-a-lost-trn:<COMMIT_SHA> PASSCODE=<auth code from https://login.london.cloud.service.gov.uk/passcode>
	cf target -s ${SPACE} > /dev/null
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make ${SPACE} get-postgres-instance-guid`))
	$(if $(BEFORE_TIME), , $(error can only run with BEFORE_TIME, eg BEFORE_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_paas_restore_db_from_db_instance=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_restore_db_from_point_in_time_before=$(BEFORE_TIME))
	echo "Restoring ${POSTGRES_DATABASE_NAME} from $(TF_VAR_paas_restore_db_from_db_instance) before $(TF_VAR_paas_restore_db_from_point_in_time_before)"
	make ${DEPLOY_ENV} terraform-apply

terraform-init:
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	[[ "${SP_AUTH}" != "true" ]] && az account set -s $(AZURE_SUBSCRIPTION) || true
	terraform -chdir=terraform init -backend-config workspace_variables/${DEPLOY_ENV}.backend.tfvars -upgrade -reconfigure

terraform-plan: terraform-init
	terraform -chdir=terraform plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

terraform-apply: terraform-init
	terraform -chdir=terraform apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

terraform-destroy: terraform-init
	terraform -chdir=terraform destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}
