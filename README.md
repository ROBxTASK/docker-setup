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
`services/docker-compose.yml`

**Configuration** is done via environment variables, which are define in `staging/services/env_vars`. Secrets can be locally stored in `staging/services/env_vars-staging`.

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

Routes are handled by the **gateway-proxy** and appear e.g. at: [https://robxtask.salzburgresearch.at/robxtask/routes](https://robxtask.salzburgresearch.at/robxtask/routes)

There are some preconfigured routes available and used from [https://github.com/nimble-platform/cloud-config](https://github.com/nimble-platform/cloud-config)
In addition to that, all running services add their own route using their own service name.
Note, that the **gateway-proxy** deployed for ROBxTASK holds specific configuration in '[env_vars-gateway-proxy](staging/infra/env_vars-gateway-proxy)'.

## Debugging options

### Debugging with a separate `tcpdump`-container (recommended)

```bash
docker build -t tcpdump - <<EOF 
FROM ubuntu 
RUN apt-get update && apt-get install -y tcpdump 
CMD tcpdump -i eth0 
EOF

# example for dumping traffic between gateway proxy and identity service
docker run --tty --net=container:robxtask-infra-staging_gateway-proxy_1 tcpdump tcpdump -N -A 'host identity-service'
```

### Enable debug logging in nginx

Two log formats are defined in nginx.conf: 'mainlogfmt' and 'debuglogfmt'. The latter can be used for debugging and will dump lots of information to the log (even confidential tokens, etc.)

### Remote debugging

Java-based services can also be remotely debugged, if required. To enable this, a debugging port needs to be accessible, e.g. by adding it in the service's docker-compose specification:

```
    ports:
      - "127.0.0.1:5005:5005"
    environment:
      JAVA_TOOL_OPTIONS: -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
```

For accessing it, ssh-port forwarding may be required: `ssh -L5005:localhost:5005 <target-machine>`