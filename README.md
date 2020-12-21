# sow-rest

## Repository structure

- docker: docker-compose based installation
- kubernetes: kubernetes based installation
- sow-rest-api: the API component (See [README](https://github.com/k8-proxy/sow-rest-api/blob/main/README.md))
- sow-rest-UI: the UI component (See [README](https://github.com/k8-proxy/sow-rest-UI/blob/develop/app/README.md))


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
