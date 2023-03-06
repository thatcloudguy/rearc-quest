# Quest Mini Project

![Architectural diagram!](/images/quest-arch.jpg "Architectural Diagram")

## Requirements
In order to deploy this project you will need the following installed:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

You will also need to configure your AWS credentials and update the variables.tf default value for aws_profile to your aws profile if it is not default.

For DNS resolution please also provide a root domain that has a public hosted zone in this aws account you are deploying into.

## Initialize
To initialize run `make initialize` at the command line
At the end of this it will give you the name to set the image to. Update the `image` variable in main.tf to this string that it provided. Once done, run `make deploy`
 
 ## Deploy
 After initialization and the `image` variable update, `make deploy` will build the docker image and will push and redeploy it

 ## Destroy
 When you are ready to destroy this stack run `make destroy`. NOTE: there is a confirmation prompt for this command because the result is destructive.

 ## Managing The Secret Word
 To update and manage the secret word please do not update in code because secrets should not be stored in plain text. Instead, please use the AWS Secrets Manager console to update the secret. Once you have updated the secret, in the console run `make tf-deploy`
 >**Warning**
>_since we are using local state in this quest do not commit your state file because TF will expand the secret in plain text there_

## Finishing the Quest
To make grading this quest more codified you can also run `make grade` to automate the grading of this quest