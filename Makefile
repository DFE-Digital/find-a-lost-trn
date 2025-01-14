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

.PHONY: development ## For AKS
development: aks test-cluster## Specify development aks environment
	$(eval include global_config/development.sh)

.PHONY: test
test: aks test-cluster ## Specify test aks environment
	$(eval include global_config/test.sh)

.PHONY: preproduction
preproduction: aks test-cluster ## Specify preproduction aks environment
	$(eval include global_config/preproduction.sh)

.PHONY: production
production: aks production-cluster ## Specify production aks environment
	$(eval include global_config/production.sh)

.PHONY: review
review: aks test-cluster ## Specify review aks environment
	$(if $(pr_id), , $(error Missing environment variable "pr_id"))
	$(eval include global_config/review.sh)
	$(eval env=-pr-$(pr_id))
	$(eval backend_config=-backend-config="key=review$(env).tfstate")
	$(eval export TF_VAR_app_suffix=$(env))

.PHONY: ci
ci:	## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)

bin/konduit.sh:
	curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/main/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh

.PHONY: vendor-modules
vendor-modules:
	rm -rf terraform/aks/vendor/modules
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/aks/vendor/modules/aks

tags: ##Tags that will be added to resource group on it's creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early years and Schools Group", "Parent Business":"Teaching Regulation Agency", "Product" : "Find a Lost TRN", "Service Line": "Teaching Workforce", "Service": "Teacher Services", "Service Offering": "Find a Lost TRN", "Environment" : "$(ENV_TAG)"}' | jq . ))

clone:
	$(eval CLONE_STRING=-clone)

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

terraform-init: vendor-modules
	[[ "${SP_AUTH}" != "true" ]] && az account set -s $(AZURE_SUBSCRIPTION) || true
	terraform -chdir=terraform/aks init -backend-config workspace_variables/$(CONFIG).backend.tfvars $(backend_config) -upgrade -reconfigure
	$(if $(DOCKER_IMAGE), $(eval export TF_VAR_app_docker_image=$(DOCKER_IMAGE)), $(error Missing environment variable "DOCKER_IMAGE"))

terraform-plan: terraform-init
	terraform -chdir=terraform/aks plan -var-file workspace_variables/$(CONFIG).tfvars.json

terraform-apply: terraform-init
	terraform -chdir=terraform/aks apply -var-file workspace_variables/$(CONFIG).tfvars.json ${AUTO_APPROVE}

terraform-destroy: terraform-init
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

.PHONY: vendor-domain-infra-modules
vendor-domain-infra-modules:
	rm -rf terraform/domains/infrastructure/vendor/modules/domains
	TERRAFORM_MODULES_TAG=stable
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/domains/infrastructure/vendor/modules/domains

domains-infra-init: faltrn_domain vendor-domain-infra-modules set-azure-account ## make domains-infra-init -  terraform init for dns core resources, eg Main FrontDoor resource
	terraform -chdir=terraform/domains/infrastructure init -reconfigure -upgrade

domains-infra-plan: domains-infra-init ## terraform plan for dns core resources
	terraform -chdir=terraform/domains/infrastructure plan -var-file config/zones.tfvars.json

domains-infra-apply: domains-infra-init ## terraform apply for dns core resources
	terraform -chdir=terraform/domains/infrastructure apply -var-file config/zones.tfvars.json ${AUTO_APPROVE}

######################################

.PHONY: vendor-domain-modules
vendor-domain-modules:
	rm -rf terraform/domains/environment_domains/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/domains/environment_domains/vendor/modules/domains

domains-init: faltrn_domain vendor-domain-modules set-azure-account ## terraform init for dns resources: make <env>  domains-init
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

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

get-cluster-credentials: set-azure-account ## make <config> get-cluster-credentials [ENVIRONMENT=<clusterX>]
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)

console: get-cluster-credentials
	kubectl -n tra-${DEPLOY_ENV} exec -ti --tty deployment/find-a-lost-trn-${DEPLOY_ENV} -- /bin/sh -c 'cd /app && /usr/local/bin/bundle exec rails c'
