# CI Workflow

For every PR merged to master, the workflow will do the following steps:

- Checkout k8-rebuild repository code
- Build docker images for k8-rebuild-rest-api and k8-rebuild-file-drop(packer)
- Install local docker registry on the VM(packer)
- Push docker images to local docker registry(packer)
- Install kubernetes cluster and deploy the helm chart with new docker images(packer)
- Create AMI from the instance(packer)
- Find the exisitng EC2 instances with name dev-k8-rebuild
- Deploy a new EC2 instance with newly created AMI
- IP address to access the file-drop UI will be displayed in "Deploy AMI to dev" step of "deploy-ami" job
- Delete the old EC2 instances.
