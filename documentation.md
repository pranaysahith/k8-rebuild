## Architecture

### The *K8-Rebuild* Architecture diagram
- ![k8_rebuild_architecture](https://user-images.githubusercontent.com/70108899/102902077-ba712280-446e-11eb-9226-1ef5efba0312.png)

*K8-REBUILD* is Kubernetes solution for Glasswall rebuild engine, working as a two component deployment.
It is combaining:
- [K8-REBUILD-REST-API](https://github.com/k8-proxy/k8-rebuild-rest-api/blob/main/README.md)

### AND

- [K8-REBUILD-FILE-DROP](https://github.com/k8-proxy/k8-rebuild-file-drop/blob/main/documentation.md)
- ![k8_file_drop_sequence_diagram](https://user-images.githubusercontent.com/70108899/102902009-9ca3bd80-446e-11eb-97e4-32ea4b84612d.png)

### The final flow follows the process:
- ![k8_rebuild_sequence_diagram](https://user-images.githubusercontent.com/70108899/102901970-8f86ce80-446e-11eb-8079-3a79afaf6071.png)

### Deployment of *K8-REBUILD* Using Docker

Run:

```shell
git clone https://github.com/k8-proxy/k8-rebuild.git
cd k8-rebuild
git submodule update --init --recursive --progress
docker-compose up --build
```
Make sure `git submodule update --init --recursive --progress` finished successufully on your network (in case you have McAfee it may need to be disabled) .
The service will be available on `http://localhost`.

### Deployment of *K8-REBUILD* Using Kubernetes
- Deploy rancher server using docker    
    ```
    docker run -d --restart=unless-stopped \
    -p 8080:80 -p 8443:443 \
    --privileged \
    rancher/rancher:latest
    ```
- Create new cluster. On how to create cluster on Rancher, you can check [here](https://rancher.com/docs/rancher/v2.x/en/quick-start-guide/deployment/quickstart-manual-setup/)
- Select etcd, control plane and worker to make sure they are installed in at least 1 node.
- Test the cluster deployment
    - Select and open the cluster to be tested. On the right top, click on "Kubeconfig File" and copy the config file data.
    - Create a local file called `kubeconfig` and paste the copied data.
    - Use this file to connect to the cluster by running below commands. Please note, in the below command the KUBECONFIG variable should be set to the path of kubeconfig file created in the previous step. It is easy to connect to the cluster, if the file is merged with `~/.kube/config`.
        ```
        export KUBECONFIG=kubeconfig
        kubectl get nodes
        kubectl get all --all-namespaces
        ```
    - Once cluster is ready, run `helm install k8-rebuild kubernetes`
    - The service should be running in your cluster as a NodePort.
    
## Use cases

- Process images that are retrieved from un-trusted sources
- Ability to use zip files in S3 buckets to provide the files needed to be rebuild
- Detect when files get dropped > get the file > unzip it > put all the files thought the Glasswall engine > capture all rebuilt files in one folder > capture all xml files in another folder > zip both folders > upload zip files to another S3 location 

![use_case_diagrams](![image](https://user-images.githubusercontent.com/64204445/102920812-62a7db00-44b1-11eb-82ae-c2d0308413fb.png)

- XML report contains information about the file that was processed, what was remidiated, sanitized or removed from original file.
- Once you rebuild the file, cleaned file can be downloaded and used later on without the worries about potential harms.

## Server Level Configuration
- Configuration is applied at server level where `Geotiff policy` is set to `Allow` (`Geotiff = ContentManagementFlagAction.Allow`)

## Healthchecks
Health Check Functional script for File Drop is also created. It checks:
- File Drop UI is available by opening website: `http://34.253.140.96/`
- Login
- Upload of a PDF file
- Getting the rebuild PDF file and XML report

More details about Healthcheck implementation and usage can be found on [HealthFunctionalTests](https://github.com/k8-proxy/vmware-scripts/tree/main/HealthFunctionalTests/filedrop) and corresponding video
[Health Check](https://www.youtube.com/watch?v=SaoC-gYxzJY)

## Importing File-Drop OVA to AWS

### Prerequisites

- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) on your local machine

    - AWS CLI installation [Linux](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html):
        ```
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        ```
    
    - AWS CLI installation [WIN](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html):
        ```
        - Download and install msi: https://awscli.amazonaws.com/AWSCLIV2.msi
        - To verify AWS CLI was installed succesufully open CMD and run `aws --version`, result should be like `aws-cli/2.1.1 Python/3.7.4 Windows/10 botocore/2.0.0`
        ```
- Run `aws configure` to [setup access](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) to AWS account
    ```
    example:
    AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
    AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    Default region name [None]: us-west-2
    Default output format [None]: json
    ```
- Create an Amazon S3 bucket (if there is not one in place) to store the exported OVA through: https://s3.console.aws.amazon.com/ [please note that the bucket must be in the same region that the VM will be imported on]

- Create an IAM role named `vmimport`. This should be done only once.
    - make sure AWS STS is enabled for the region you're working on
    - create a file called `trust-policy.json` and add the following:
    ```
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": { "Service": "vmie.amazonaws.com" },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals":{
                "sts:Externalid": "vmimport"
                }
            }
        }
    ]
    }
    ```
    - From folder where `trust-policy.json` is created, run the `create-role` command
    ```
    aws iam create-role --role-name vmimport --assume-role-policy-document "file://trust-policy.json"
    ```
    - Create a file called `role-policy.json`, replacing `disk-image-file-bucket` with the bucket for disk images and `export-bucket` with the bucket for exported images:
    ```
    {
    "Version":"2012-10-17",
    "Statement":[
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket" 
            ],
            "Resource": [
                "arn:aws:s3:::disk-image-file-bucket",
                "arn:aws:s3:::disk-image-file-bucket/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetBucketAcl"
            ],
            "Resource": [
                "arn:aws:s3:::export-bucket",
                "arn:aws:s3:::export-bucket/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:ModifySnapshotAttribute",
                "ec2:CopySnapshot",
                "ec2:RegisterImage",
                "ec2:Describe*"
            ],
            "Resource": "*"
        }
    ]
    }
    ```
    - From folder where `role-policy.json` is created, run the `put-role-policy` command to attach the policy to the role created:
    ```
    aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://role-policy.json"
    ```

### Importing the OVA
- From local cmd, run the `import-image` command:
    - Create `containers.json` file as per example:
        ```
        [
        {
            "Description": "My Server OVA",
            "Format": "ova",
            "UserBucket": {
                "S3Bucket": "my-import-bucket",
                "S3Key": "vms/my-server-vm.ova"
            }
        }]
    - Navigate to folder where `containers.json` is located and run: 
         ```
         aws ec2 import-image --description "My server VM" --disk-containers "file://containers.json"
         ```

- monitor an import image task, replaceing the `task ID`
    ```
    aws ec2 describe-import-image-tasks --import-task-ids import-ami-1234567890abcdef0
    ```
    - an example of a completed import 
    ```
    {
        "ImportImageTasks": [
            {
                "ImportTaskId": "import-ami-01234567890abcdef",
                "ImageId": "ami-1234567890EXAMPLE",
                "SnapshotDetails": [
                    {
                        "DiskImageSize": 705638400.0,
                        "Format": "ova",
                        "SnapshotId": "snap-111222333444aaabb"
                        "Status": "completed",
                        "UserBucket": {
                            "S3Bucket": "my-import-bucket",
                            "S3Key": "vms/my-server-vm.ova"
                        }
                    }
                ],
                "Status": "completed"
            }
        ]
    }
    ```

### Launching instance

- navigate to EC2 console: https://console.aws.amazon.com/ec2/
- change region to the region of imported VM
- from the dashboard, choose `Launch instance`, and on the top right, choose `Search by Systems Manager Parameter` and search by `ImageId` from the earlier import output.
- select the AMI from the list and choose `Select` > choose `t2.micro`
- Review Instance Launch and select or create Key Pair. When key pair is downloaded and all information is reviewed, you can launch the VM.
- Enable inbound traffic to your instance by clicking on your instance's ID > security > Edit inbound rule > add rule > Type: SSH > source: 0.0.0.0/0
- to SSH into the instance, you need to run the following command first:
    ```
    chmod 400 my-key-pair.pem
    ```
    - you can now SSH into the instance by running, replace `my-instance-user-name` with `user` and `my-instance-public-dns-name` can be found in instance details > Public IPv4 DNS:
        ```
        ssh -i /path/my-key-pair.pem my-instance-user-name@my-instance-public-dns-name
        ```
    - use the password `secret`
- restart k3s service 
    ```
    sudo systemctl restart k3s
    ```
- From a web browser, navigate to the VM IP address over HTTP and port 30080 (i.e: http://:30080) to access the UI
- Click on login (no credentials needed) and rebuild a file
