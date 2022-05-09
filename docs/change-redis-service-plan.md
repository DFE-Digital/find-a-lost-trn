# Change Redis service plan

## 1. Change the terraform variable

Terraform variable `redis_service_plan` by default will deploy **tiny-6_x**. Make sure you have changed the default value if you are upgrading Redis service plan by overriding the default in terraform/workspace_variables/<ENV>.tfvars.json.

To list available Redis service plans, run `cf marketplace |grep redis` on CF CLI.

## 2. Change service plan

Terraform apply will recreate a new redis instance based on the new `redis_service_plan` variable value. Run:

`make <ENV> terraform-apply-replace-redis PASSCODE="XXX"`

Running the command above will prompt for terraform variable if you dont pass it as arguments to the command in **TF_VAR_name_of_variable=VALUE** form.

- var.flt_docker_image

  You can pass the image url found from the Github [packages](https://github.com/DFE-Digital/find-a-lost-trn/pkgs/container/find-a-lost-trn). For example **ghcr.io/dfe-digital/find-a-lost-trn:19486740313c9c89566bcfa4d1f60981d27fb2e3**

  Find the current version of the Github SHA of image by running `cf app APP_NAME` on CF CLI, where APP_NAME is the name of the app for the environment you are deploying. Make sure you use the same image as the current one deployed.

Review the generated deploy plan and make sure there are no changes to the **flt_docker_image** property of the app as we are deploying the app again with the same version. Terraform plan will have new Redis, Redis service key, and app to be replaced.
