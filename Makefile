TERRAFILE_VERSION=0.8
.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

##@ Set environment and corresponding configuration

SERVICE_SHORT=faltrn


.PHONY: aks
aks:  ## Sets environment variables for aks deployment
	$(eval PLATFORM=aks)
	$(eval REGION=UK South)
	$(eval STORAGE_ACCOUNT_SUFFIX=sa)
	$(eval KEY_VAULT_SECRET_NAME=APPLICATION)
	$(eval KEY_VAULT_PURGE_PROTECTION=false)

.PHONY: dev ## For Paas only
dev:
	$(eval DEPLOY_ENV=dev)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval RESOURCE_NAME_PREFIX=s165d01)
	$(eval ENV_SHORT=dv)
	$(eval ENV_TAG=dev)

.PHONY: development_aks ## For AKS
development_aks: aks ## Specify development aks environment
	$(eval include global_config/development_aks.sh)

.PHONY: test
test:
	$(eval DEPLOY_ENV=test)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=ts)
	$(eval ENV_TAG=test)

.PHONY: test_aks
test_aks: aks ## Specify test aks environment
	$(eval include global_config/test_aks.sh)

.PHONY: preprod
preprod:
	$(eval DEPLOY_ENV=preprod)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=pp)
	$(eval ENV_TAG=pre-prod)

.PHONY: preproduction_aks
preproduction_aks: aks ## Specify preproduction aks environment
	$(eval include global_config/preproduction_aks.sh)

.PHONY: production
production:
	$(eval DEPLOY_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-production)
	$(eval RESOURCE_NAME_PREFIX=s165p01)
	$(eval ENV_SHORT=pd)
	$(eval ENV_TAG=prod)
	$(eval AZURE_BACKUP_STORAGE_ACCOUNT_NAME=s165p01dbbackup)
	$(eval AZURE_BACKUP_STORAGE_CONTAINER_NAME=find-a-lost-trn)

.PHONY: production_aks
production_aks: aks ## Specify production aks environment
	$(eval include global_config/production_aks.sh)

.PHONY: review
review:
	$(if $(pr_id), , $(error Missing environment variable "pr_id"))
	$(eval DEPLOY_ENV=review)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval env=-pr-$(pr_id))
	$(eval backend_config=-backend-config="key=review/review$(env).tfstate")
	$(eval export TF_VAR_app_suffix=$(env))

.PHONY: review_aks
review_aks: aks ## Specify review aks environment
	$(if $(pr_id), , $(error Missing environment variable "pr_id"))
	$(eval include global_config/review_aks.sh)
	$(eval env=-pr-$(pr_id))
	$(eval backend_config=-backend-config="key=review_aks$(env).tfstate")
	$(eval export TF_VAR_app_suffix=$(env))

.PHONY: ci
ci:	## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)

bin/konduit.sh:
	curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/main/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh

bin/terrafile: ## Install terrafile to manage terraform modules
	curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile

tags: ##Tags that will be added to resource group on it's creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early years and Schools Group", "Parent Business":"Teaching Regulation Agency", "Product" : "Find a Lost TRN", "Service Line": "Teaching Workforce", "Service": "Teacher Services", "Service Offering": "Find a Lost TRN", "Environment" : "$(ENV_TAG)"}' | jq . ))

.PHONY: read-keyvault-config
read-keyvault-config:
	$(eval KEY_VAULT_NAME=$(shell jq -r '.key_vault_name' terraform/paas/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval KEY_VAULT_SECRET_NAME=INFRASTRUCTURE)

read-deployment-config:
	$(eval SPACE=$(shell jq -r '.paas_space' terraform/paas/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval POSTGRES_DATABASE_NAME=$(shell jq -r '.postgres_database_name' terraform/paas/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval FLT_APP_NAME=$(shell jq -r '.flt_app_name' terraform/paas/workspace_variables/$(DEPLOY_ENV).tfvars.json))

##@ Query parameter store to display environment variables. Requires Azure credentials
set-azure-account: ${environment}
	echo "Logging on to ${AZURE_SUBSCRIPTION}"
	az account set -s ${AZURE_SUBSCRIPTION}

.PHONY: install-fetch-config
install-fetch-config: ## Install the fetch-config script, for viewing/editing secrets in Azure Key Vault
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

edit-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

print-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml

validate-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
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

restore-data-from-backup: read-deployment-config # make production restore-data-from-backup CONFIRM_RESTORE=YES BACKUP_FILENAME="find-a-lost-trn-production-pg-svc-2022-04-28-01"
	@if [[ "$(CONFIRM_RESTORE)" != YES ]]; then echo "Please enter "CONFIRM_RESTORE=YES" to run workflow"; exit 1; fi
	$(eval export AZURE_BACKUP_STORAGE_ACCOUNT_NAME=$(AZURE_BACKUP_STORAGE_ACCOUNT_NAME))
	$(if $(BACKUP_FILENAME), , $(error can only run with BACKUP_FILENAME, eg BACKUP_FILENAME="find-a-lost-trn-production-pg-svc-2022-04-28-01"))
	bin/download-db-backup ${AZURE_BACKUP_STORAGE_ACCOUNT_NAME} ${AZURE_BACKUP_STORAGE_CONTAINER_NAME} ${BACKUP_FILENAME}.tar.gz
	bin/restore-db ${DEPLOY_ENV} ${CONFIRM_RESTORE} ${SPACE} ${BACKUP_FILENAME}.sql ${POSTGRES_DATABASE_NAME}

terraform-init:
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	[[ "${SP_AUTH}" != "true" ]] && az account set -s $(AZURE_SUBSCRIPTION) || true
	terraform -chdir=terraform/paas init -backend-config workspace_variables/${DEPLOY_ENV}.backend.tfvars $(backend_config) -upgrade -reconfigure

terraform-plan: terraform-init
	terraform -chdir=terraform/paas plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

terraform-apply: terraform-init
	terraform -chdir=terraform/paas apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

terraform-apply-replace-redis: terraform-init # make dev terraform-apply-replace-redis PASSCODE="XXX"
	terraform -chdir=terraform/paas apply -replace="cloudfoundry_service_instance.redis" -replace="cloudfoundry_app.app" -replace="cloudfoundry_service_key.redis_key" -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

terraform-destroy: terraform-init
	terraform -chdir=terraform/paas destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

terraform-init-aks: bin/terrafile
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	[[ "${SP_AUTH}" != "true" ]] && az account set -s $(AZURE_SUBSCRIPTION) || true
	./bin/terrafile -p terraform/aks/vendor/modules -f terraform/aks/workspace_variables/$(CONFIG)_Terrafile
	terraform -chdir=terraform/aks init -backend-config workspace_variables/$(CONFIG).backend.tfvars $(backend_config) -upgrade -reconfigure
	$(if $(IMAGE_TAG), , $(eval export IMAGE_TAG=2ad42e8958a4d63ed295a58a0847430705725ba8))
	$(eval export TF_VAR_paas_app_docker_image=ghcr.io/dfe-digital/find-a-lost-trn:$(IMAGE_TAG))

terraform-plan-aks: terraform-init-aks
	terraform -chdir=terraform/aks plan -var-file workspace_variables/$(CONFIG).tfvars.json

terraform-apply-aks: terraform-init-aks
	terraform -chdir=terraform/aks apply -var-file workspace_variables/$(CONFIG).tfvars.json ${AUTO_APPROVE}

terraform-destroy-aks: terraform-init-aks
	terraform -chdir=terraform/aks destroy -var-file workspace_variables/$(CONFIG).tfvars.json ${AUTO_APPROVE}

deploy-azure-resources: set-azure-account tags # make dev deploy-azure-resources CONFIRM_DEPLOY=1
	$(if $(CONFIRM_DEPLOY), , $(error can only run with CONFIRM_DEPLOY))
	az deployment sub create -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/main/azure/resourcedeploy.json" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-faltrn-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' "environment=${DEPLOY_ENV}" "tfStorageAccountName=${RESOURCE_NAME_PREFIX}faltrntfstate${ENV_SHORT}" "tfStorageContainerName=faltrn-tfstate" "dbBackupStorageAccountName=false" "dbBackupStorageContainerName=false" "keyVaultName=${RESOURCE_NAME_PREFIX}-faltrn-${ENV_SHORT}-kv"

validate-azure-resources: set-azure-account tags # make dev validate-azure-resources
	az deployment sub create -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/main/azure/resourcedeploy.json" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-faltrn-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' "environment=${DEPLOY_ENV}" "tfStorageAccountName=${RESOURCE_NAME_PREFIX}faltrntfstate${ENV_SHORT}" "tfStorageContainerName=faltrn-tfstate" "dbBackupStorageAccountName=false" "dbBackupStorageContainerName=false" "keyVaultName=${RESOURCE_NAME_PREFIX}-faltrn-${ENV_SHORT}-kv" --what-if

.PHONY: set-azure-template-tag
set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.6)

.PHONY: set-what-if
set-what-if:
	$(eval WHAT_IF=--what-if)

.PHONY: faltrn_domain
faltrn_domain:   ## runs a script to config variables for setting up dns
	$(eval include global_config/domain.sh)
	echo "processed script"

.PHONY: set-resource-group-name
set-resource-group-name:
	$(eval RESOURCE_GROUP_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-rg)

.PHONY: set-azure-resource-group-tags
set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early years and Schools Group", "Parent Business":"Teaching Regulation Agency", "Product" : "Find a Lost TRN", "Service Line": "Teaching Workforce", "Service": "Teacher Services", "Service Offering": "Find a Lost TRN", "Environment" : "$(ENV_TAG)"}' | jq . ))

.PHONY: set-storage-account-name
set-storage-account-name:
	$(eval STORAGE_ACCOUNT_NAME=$(AZURE_RESOURCE_PREFIX)$(SERVICE_SHORT)tfstate$(CONFIG_SHORT)sa)

.PHONY: set-key-vault-names
set-key-vault-names:
	$(eval KEY_VAULT_APPLICATION_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-app-kv)
	$(eval KEY_VAULT_INFRASTRUCTURE_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-inf-kv)


domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## deploy container to store terraform state for all dns resources -run validate first
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}


domains-infra-init: faltrn_domain set-azure-account ## make domains-infra-init -  terraform init for dns core resources, eg Main FrontDoor resource
	terraform -chdir=terraform/domains/infrastructure init -reconfigure -upgrade

domains-infra-plan: domains-infra-init ## terraform plan for dns core resources
	terraform -chdir=terraform/domains/infrastructure plan -var-file config/zones.tfvars.json

domains-infra-apply: domains-infra-init ## terraform apply for dns core resources
	terraform -chdir=terraform/domains/infrastructure apply -var-file config/zones.tfvars.json ${AUTO_APPROVE}


######################################

domains-init: faltrn_domain set-azure-account ## terraform init for dns resources: make <env>  domains-init
	terraform -chdir=terraform/domains/environment_domains init -upgrade -reconfigure -backend-config=key=$(or $(DOMAINS_TERRAFORM_BACKEND_KEY),faltrndomains_$(DEPLOY_ENV).tfstate)

domains-plan: domains-init  ## terraform plan for dns resources, eg dev.<domain_name> dns records and frontdoor routing
	terraform -chdir=terraform/domains/environment_domains plan -var-file config/$(DEPLOY_ENV).tfvars.json

domains-apply: domains-init ## terraform apply for dns resources
	terraform -chdir=terraform/domains/environment_domains apply -var-file config/$(DEPLOY_ENV).tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init ## terraform destroy for dns resources
	terraform -chdir=terraform/domains/environment_domains destroy -var-file config/$(DEPLOY_ENV).tfvars.json


arm-deployment: set-resource-group-name set-storage-account-name set-azure-template-tag set-azure-account set-azure-resource-group-tags set-key-vault-names ## deploy container/kv to store terraform state for each environment
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_GROUP_NAME}" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${STORAGE_ACCOUNT_NAME}" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			keyVaultNames='("${KEY_VAULT_APPLICATION_NAME}", "${KEY_VAULT_INFRASTRUCTURE_NAME}")' \
			"enableKVPurgeProtection=${KEY_VAULT_PURGE_PROTECTION}" ${WHAT_IF}
