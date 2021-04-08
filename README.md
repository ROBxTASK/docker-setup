# docker-setup

ROBxTASK Docker Deployment Setup for remote `staging` environment. Setting up a local development environment is desribed in [dev/README.md](`dev/README.md`))

This project-specific setup is manages several docker containers grouped in separate directories:

(**NB:** For remote deployment we recommend using the provided [fabricate](https://www.fabfile.org/) file: `fab deploy logs -H <username>@<host>`
)

## ROBxTASK CI/CD Server using [Jenkins](https://www.jenkins.io/)

- **Directory Name**: `jenkins_ci`
- **Configuration**: `jenkins_ci/docker-compose.yml`
- **Docker File**: `jenkins_ci/Dockerfile`

## ROBxTASK Microservice Infrastructure

The platform is split into two different kind of components:

1. Infrastructure components (directory `infra`)
2. Microservice components (directory `services`)

### Infrastructure Components

#### Identity Management / Authorisation Service using [Keycloak 4](https://www.keycloak.org/)

- **Container Name**: `keycloack_1`
- **Configuration**: `keycloak/docker-compose.yml`

These componentes are part of the virtual network with the name `infra_default`.
More information can be found bey executing `docker network inspect infra_default`
on the Docker host.

#### Infrastructure for Microservices

Defintion can be found in `infra/docker-compose.yml`, which consists of the following components:

- Config Server:

  - **ServiceID**: config-server

- Service Discovery:
  - **ServiceID**: service-discovery

- Gateway Proxy:
  - **ServiceID**: gateway-proxy

- Hystrix Dashboard (not used at the moment)
  - **ServiceID**: hystrix-dashboard

### Microservice Components

Each docker container contains usually only one (micro)-service, connected
containers are started together using `docker-compose`

The deployment is composed of infrastructure componentes and the actual
Microservices. A utility script with the name `run.sh` can
be found in the directories of each setup.


Definition and configuration of the deployment can be found in
`services/docker-compose.yml` and defines the follwing services:

- Identity Service
  - **ServiceID**: identity-service
  - **Container Name**: iassetprod_identity-service_1
- Business Process Service
  - **ServiceID**: business-process-service
  - **Container Name**: iassetprod_business-process-service_1
- Catalog Service
  - **ServiceID**: catalog-service-srdc
  - **Container Name**: iassetprod_catalog-service-srdc_1
- Frontend Service
  - **ServiceID**: frontend-service
  - **Container Name**: iassetprod_frontend-service_1
- Frontend Service Sidecar
  - **ServiceID**: frontend-service-sidecar
  - **Container Name**: iassetprod_frontend-service-sidecar_1

**Configuration** is done via environment variables, which are define in `prod/services/env_vars`. Secrets are stored in `prod/services/env_vars-prod` (this file is adapted on the hosting machine).

### Utility Script

A utility script can be found in `run-staging.sh`, which provides the following functionalies:

- `run-staging.sh infra`: starts all infrastructure components
- `run-staging.sh keycloak`: starts the Keycloak container
- `run-staging.sh marmotta`: starts the Marmotta container
- `run-staging.sh elk`: start all ELK components
- `run-staging.sh services`: starts all serivces (note: make sure the infastructue is set up appropriately)
- `run-staging.sh infra-logs`: print logs of all microservice components to stdout
- `run-staging.sh services-logs`: print logs of all services to stdout
- `run-staging.sh restart-single <serviceID>`: restart a single service


## Reverse Proxy for external service visibility

- `nginx`: container for the webserver and reverse proxy (i.e. nginx)
- **Configuration**: `nginx/docker-compose.yml`
- **Nginx Configuration**: `nginx/nginx.conf`

## A note about service routes

Routes are handled by the gateway-proxy and appear e.g. at: https://robxtask.salzburgresearch.at/robxtask/routes
There are some preconfigured routes available and used from https://github.com/nimble-platform/cloud-config
In addition to that, all running services add their own route using their own service name.
