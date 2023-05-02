## Chirper-App-Utils

This repo is used to easy build and run Chirper-app microservices easily to simulate the way Kubernetes will run these apps

## How to use this repo

1. Clone this repo and all other microservices for this project in a folder. Your folder structure should be looking like this

```
  projects/
  └── ng-chirper-app/
  │   └── src/
  └── chirper-app-api-image-filter/
  │   └── main.go
  └── chirper-app-api-user/
  │   └── main.go
  └── chirper-app-api-tweet/
  │   └── main.go
  └── chirper-app-reverse-proxy/
  │   └── nginx.conf
  └── chirper-app-utils/ ………………… you be inside this folder
    ├── certs/
    ├── k8s/
    │  ├── dockerconfig.json
    │  └── rest of the *.yaml files
    ├── docker-compose.yml
    ├── .netrc
    ├── app.env
    └── rest of the files you cloned
```

1. Remove unused and dangling images `docker image prune --all`
1. Clone the repos, [ng-chirper-app](https://github.com/okpalaChidiebere/ng-chirper-app), [chirper-app-api-image-filter](https://github.com/okpalaChidiebere/chirper-app-api-image-filter), [chirper-app-api-user](https://github.com/okpalaChidiebere/chirper-app-api-user), [chirper-app-api-tweet](https://github.com/okpalaChidiebere/chirper-app-api-tweet), [chirper-app-reverse-proxy](https://github.com/okpalaChidiebere/chirper-app-reverse-proxy)
1. Create `.netrc` file as specified in the diagram above. The content of the file will be `machine github.com\n  login <GIT_ACCESS_USER_TOKEN>"` You can get this token from (here)[https://github.com/settings/tokens/new]. This token is needed because to build the go backend services, we need to get the go private module [chirper-app-gen-protos](https://github.com/okpalaChidiebere/chirper-app-gen-protos). If your github account don't access to the code your build will fail. So maybe contact me :)
1. Create a `app.env` file

```env
AWS_REGION=ca-central-1
AWS_PROFILE=aws-cli-user
```

1. Then, build the images locally using `docker compose build --parallel`. NOTE: the command will work as long as you have the docker-compose.yml file present
1. Generate ssl certificates for the nginx proxy server to use by running `make cert`
1. Then you can run `docker compose up`
1. Access the front-end using [http://localhost:4200](http://localhost:4200)

## Resources Needed for this chirper-app

- We need to AWS Dynamodb two tables `chirper-app-users-dev` and `chirper-app-tweets-dev` and an S3 bucket to store user images `chirper-app-thumbnail-dev`
- I used CloudFormation to easily help you spin up and spin down these resources. This [Article](https://dev.to/aws-builders/aws-cli-cloudformation-stack-with-template-on-s3-1elb) explained pretty much all the steps i took to make this happen
- Go to the [file](https://github.com/okpalaChidiebere/ng-chirper-app/blob/master/src/app/utils/_DATA.ts), then the commented list you can use as data for the migration endpoints for both the tweets and user apis

## BackEnd gRPC Endpoints

- I prefer to use Postman. Clone this [repo](https://github.com/okpalaChidiebere/chirper-app-apis) and import them the API you want to test to postman. You can watch this [video](https://www.youtube.com/watch?v=yluYiCj71ss) to see how to test protos using file imports
- To create a grpc request, open a `new` grpc tab in postman by clicking the new button and selecting 'gRPC request' in the modal that opens, then enter the `http://localhost:8080`. port 8080 is the nginx reverseproxy server that orchestrates the requests to the services(servers)
- If you don't want to clone the repo, you the enter the actual port of the service you want eg `localhost:9000` to access the `chirper-app-api-image-filter` microservice then use grpc reflection to load the service definitions from the second input box beside where you enter the `<host>:<port>` for the gRPC server. The after you can change the port back to `chirper-app-reverse-proxy` if you want to access the services through the verse proxy which you should :)
- More videos about postman gRPC [here](https://www.youtube.com/watch?v=RbHOs2xchGE)

## BackEnd HTTP/1.1 Endpoints

- `http://localhost:8080/<path>` to see all invoke all endpoints
- You can also access the

## Useful commands

- `docker compose build ng-chirper-app use --no-cache` to force a rebuild of an existing image

- `docker compose build --parallel` to build all images in parallel. This

- `docker network ls` list all current networks that are already created by docker locally. This is useful when we have the `networks: blocks` in our compose yml file and we want to use one of the networks from the list to attach to containers in being created up by docker. [see](https://docs.docker.com/compose/networking/#use-a-pre-existing-network)

- `docker ps` to see all standalone containers running; whether they are under thesame network with docker compose or not

```yml
networks:
  network1:
    name: chirper-app-utils_default #assuming we know its in the list
    external: true
```

- `docker network inspect <network_name>` to see details regarding a network. This us useful when you want to confirm that all containers currently running by docker compose can talk to each other under the same network when needed. Compose creates a network named default for you automatically and attach them to all running containers to use to communicate to each other; you do not need the manual 'networks: blocks' in the compose yaml file. Eg: the docker compose by default create a network called `chirper-app-utils_default`. and can invoke the ip address directly on ur local machine

- `docker inspect your_container_name` to find the IP address of the container; you will see the IP in Networks section. Alternatively, you can run `docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' your_container_name` to see exact IP address of that container running if you don't want to read through the blob of data from the first command :). Each container has a different IP address, in order to connect from one container to another you need to know the container IP address that you want to connect. 127.0.0.1 is not the container IP, it's the host IP. Be aware that IPAddress if the container can change when you restart the container so it's better to use container(service) name.

- `docker logs <containerName>` to see all logs for a container running

- `docker compose up <service_name_1> <service_name_2>`

## Simple http2 curl request

```bash
curl \
 --http2 http://localhost:1443/user.v1.UserService/ListUsers \
 --http2-prior-knowledge \
 -X POST \
 --header "Content-Type: application/json" \
 --data '{"limit": 0,"next_key": ""}' \
 -v
```

[https://everything.curl.dev/http/versions](https://everything.curl.dev/http/versions)

## Simple http2 HEAD curl request

```bash
curl --http2 -I http://localhost:1443/user.v1.UserService/ListUsers --http2-prior-knowledge -v --header "Content-Type: application/json"
```

## simple http secure curl request

```bash
curl -v --key /Users/chidiebere/Desktop/projects/chirper-app-utils/certs/server_key.pem --cert /Users/chidiebere/Desktop/projects/chirper-app-utils/certs/server_cert.pem https://localhost:8083/api/v0/tweets/limit/30/next_key/
```

## Possible issues you may run into

https://stackoverflow.com/questions/39525820/docker-port-forwarding-not-working
