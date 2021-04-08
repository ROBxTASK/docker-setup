#!/bin/bash

INFRA_PROJECT=robxtask-infra-staging
SERVICE_PROJECT=robxtask-services-staging


# run infrastructure
if [[ "$1" = "infra" ]]; then
	docker network create staging_infra_default || true
	docker-compose -f infra/docker-compose.yml --project-name ${INFRA_PROJECT} up --build -d --remove-orphans

elif [[ "$1" = "database" ]]; then
	docker-compose -f infra/docker-compose.yml --project-name ${INFRA_PROJECT} up -d --remove-orphans staging-main-db

elif [[ "$1" = "keycloak" ]]; then
	docker-compose -f infra/keycloak/docker-compose.yml --project-name ${INFRA_PROJECT}-keycloak up --build -d --remove-orphans

elif [[ "$1" = "solr" ]]; then
	docker-compose -f infra/solr/docker-compose.yml --project-name ${INFRA_PROJECT}-solr up --build -d --remove-orphans

#elif [[ "$1" = "elk" ]]; then
#	docker-compose -f infra/elk/docker-compose-elk.yml --project-name ${INFRA_PROJECT}-elk up --build -d --remove-orphans

elif [[ "$1" = "services" ]]; then
	# update services
	docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} pull

	# start services
	docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} up \
		-d \
		--remove-orphans \
		--build \
		identity-service frontend-service frontend-service-sidecar asset-indexing-service semantic-lookup-service

elif [[ "$1" = "start" ]]; then
	update_images
	start_all

elif [[ "$1" = "stop" ]]; then
	docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} stop
	docker-compose -f infra/docker-compose.yml --project-name ${INFRA_PROJECT} stop

elif [[ "$1" = "down" ]]; then
	read -p "Are you sure to also remove volumes? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
		docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} down -v
		docker-compose -f infra/docker-compose.yml --project-name ${INFRA_PROJECT} down -v
		docker-compose -f infra/docker-compose.yml --project-name ${INFRA_PROJECT}-solr down -v
		docker-compose -f infra/docker-compose.yml --project-name ${INFRA_PROJECT}-keycloak down -v
    fi

elif [[ "$1" = "stop-services" ]]; then
	docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} stop

elif [[ "$1" = "restart-single" ]]; then
	# update services
	docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} pull $2

	# restart service
	docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} up --build -d --force-recreate $2

elif [[ "$1" = "services-logs" ]]; then
	docker-compose -f services/docker-compose.yml --project-name ${SERVICE_PROJECT} logs -f
	
else
    echo "Invalid usage"
    exit 2
fi
