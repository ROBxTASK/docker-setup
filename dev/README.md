# docker-setup

ROBxTASK Docker Deployment Setup for local `dev` environment.

## (Local) Docker Development Deployment

This section provides detailed information on how to set up a local development deployment using Docker. Required files are located in the this directory.

Recommended System Requirements (for Docker)

- 16GB Memory
- 4 CPUs

Minimum System Requirements (for Docker)

- 10GB Memory / 2 CPUs

A utility script called `run-dev.sh` provides the following main commands:

- `run-dev.sh infrastructure`: starts all microservice infrastructure components
- `run-dev.sh services`: starts all iasset core services (note: make sure the infrastructue is running appropriately before)
- `run-dev.sh start`: starts infrastructure and services (not recommended at the first time)
- `run-dev.sh stop`: stop all services

It is recommended to start the infrastructure and the services in separate terminals for easier debugging.

### Starting microservice infrastructure

`./run-dev.sh infrastructure`: log output will be shown in the terminal

Before continuing to start services, check the infrastructure components as follows:

- `docker ps` should show 7 new containers up and running:

```bash
$ docker ps --format 'table {{.Names}}\t{{.Ports}}'
NAMES                                     PORTS
dev_infra_kafka_1                         0.0.0.0:9092->9092/tcp
dev_infra_zoo1_1                          2888/tcp, 0.0.0.0:2181->2181/tcp, 3888/tcp
dev_infra_gateway-proxy_1                 0.0.0.0:80->80/tcp
dev_infra_service-discovery_1             0.0.0.0:8761->8761/tcp
dev_infra_keycloak_1                      0.0.0.0:8080->8080/tcp, 0.0.0.0:8443->8443/tcp
dev_infra_solr_1                          0.0.0.0:8983->8983/tcp
dev_infra_dev-main-db_1                   0.0.0.0:5432->5432/tcp
dev_infra_config-server_1                 0.0.0.0:8888->8888/tcp
dev_infra_keycloak-db_1                   5432/tcp
dev_infra_maildev_1                       25/tcp, 0.0.0.0:8025->80/tcp
```

In case of port binding errors, the shown default port mappings can be adapted to local system requirements in `infra/docker-compose.yml`.

The infrastructure services can be tested by the following http-requests:

- <http://localhost:8888/env> => list configuration properties from `dev_infra_config-server_1`
- <http://localhost:8761/> => list registered services from Eureka `dev_infra_service-discovery_1` (only "gateway-proxy" in the beginning)
- <http://localhost/mappings> => list of mappings provided by the `dev_infra_gateway-proxy_1`
- <http://localhost:8080>, <https://localhost:8443> => Administration console for managing identities and access control from `dev_infra_keycloak_1`. Login with `admin` and password `password`

### Starting the core services (originating from NIMBLE and i-Asset)

`./run-dev.sh services`: log output will be shown in the terminal

- `docker ps` should show additional 16 containers up and running

```bash
$ docker ps --format 'table {{.Names}}\t{{.Ports}}'
NAMES                                     PORTS
dev_services_identity-service_1           0.0.0.0:9096->9096/tcp
dev_infra_kafka_1                         0.0.0.0:9092->9092/tcp
dev_infra_zoo1_1                          2888/tcp, 0.0.0.0:2181->2181/tcp, 3888/tcp
dev_services_frontend-service_1           0.0.0.0:8081->8080/tcp
dev_services_indexing-service_1           8084/tcp, 0.0.0.0:9101->8080/tcp
dev_services_frontend-service-sidecar_1   0.0.0.0:9097->9097/tcp
dev_infra_gateway-proxy_1                 0.0.0.0:80->80/tcp
dev_infra_service-discovery_1             0.0.0.0:8761->8761/tcp
dev_infra_keycloak_1                      0.0.0.0:8080->8080/tcp, 0.0.0.0:8443->8443/tcp
dev_infra_solr_1                          0.0.0.0:8983->8983/tcp
dev_infra_dev-main-db_1                   0.0.0.0:5432->5432/tcp
dev_infra_config-server_1                 0.0.0.0:8888->8888/tcp
dev_infra_keycloak-db_1                   5432/tcp
dev_infra_maildev_1                       25/tcp, 0.0.0.0:8025->80/tcp
...
```

Port mappings can be adapted in `services/docker-compose.yml`.

Once the services are up, they should show up in the EUREKA Service Discovery. Depending on available resources this will take a while.

- <http://localhost:8761/>

If they are all up, they can be tested via the platform frontend at:

- <http://localhost/frontend/>

