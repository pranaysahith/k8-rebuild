## Architecture



*K8-REBUILD* is Kubernetes solution for Glasswall rebuild engine, working as a two component deployment.
It is combaining:
- [K8-REBUILD-REST-API](https://github.com/k8-proxy/k8-rebuild-rest-api/blob/main/README.md)
- ![Workflow2](https://user-images.githubusercontent.com/70108899/102875480-225e4380-4444-11eb-8507-670a03cc2a0b.png)

### AND

- [K8-REBUILD-FILE-DROP](https://github.com/k8-proxy/k8-rebuild-file-drop/blob/main/documentation.md)
- ![Workflow1](https://user-images.githubusercontent.com/70108899/102875454-183c4500-4444-11eb-872d-d98becd850f5.png)


### The final flow follows the process:
- ![workflow7](https://user-images.githubusercontent.com/70108899/102874022-30ab6000-4442-11eb-8144-839d063d524b.png)


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


## Use cases

- Process images that are retrieved from un-trusted sources
- Ability to use zip files in S3 buckets to provide the files needed to be rebuild
- Detect when files get dropped > get the file > unzip it > put all the files thought the Glasswall engine > capture all rebuilt files in one folder > capture all xml files in another folder > zip both folders > upload zip files to another S3 location 

Whole process can be verified using the healthchecks:
[Health Check](https://glasswallsolu-qbp1117.slack.com/files/U019TEM94L9/F01GZ8B7T8F/health_checks_and_functional_health_checks.mp4)