# sow-rest

## Deployment

### Using Docker

Run:

```shell
git submodule update --init --recursive --progress
docker-compose up --build
```

The service will be available on port 80.

## BUILD & RUN API LOCAL FROM sources

    cd sow-rest-api
    docker build -t sow-rest-api --file Source/Service/Dockerfile .  
    docker run -it --rm -p 8888:80 sow-rest-api


NOTES
- Change endpoints for Frontend. Create (or edit) file ```sow-rest-UI/app/.env.development.local``` and add content:  

        REACT_APP_ANALYSE_API_ENDPOINT = 'http://localhost:8888'
        REACT_APP_FILETYPEDETECTION_API_ENDPOINT = 'http://localhost:8888'
        REACT_APP_REBUILD_API_ENDPOINT = 'http://localhost:8888'

- Can be choosed arbitrary port instead of **8888** 
