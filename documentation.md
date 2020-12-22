## Architecture



*K8-REBUILD* is Kubernetes solution for Glasswall rebuild engine, working as a two component deployment.
It is combaining:
- [K8-REBUILD-REST-API](https://github.com/k8-proxy/k8-rebuild-rest-api/blob/main/README.md)

### AND

- [K8-REBUILD-FILE-DROP](https://github.com/k8-proxy/k8-rebuild-file-drop/blob/main/documentation.md)
- ![k8_file_drop_sequence_diagram](https://user-images.githubusercontent.com/70108899/102902009-9ca3bd80-446e-11eb-97e4-32ea4b84612d.png)

### The final flow follows the process:
- ![k8_rebuild_sequence_diagram](https://user-images.githubusercontent.com/70108899/102901970-8f86ce80-446e-11eb-8079-3a79afaf6071.png)

### The *K8-Rebuild* Architecture diagram
- ![k8_rebuild_architecture](https://user-images.githubusercontent.com/70108899/102902077-ba712280-446e-11eb-9226-1ef5efba0312.png)


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

![use_case_diagrams](https://user-images.githubusercontent.com/70108899/102909171-db3e7580-4478-11eb-8deb-a6140499d5c8.png)

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
