#!/bin/bash

update_images () { 
	# update infrastructure
	docker-compose -f infra/docker-compose.yml --project-name dev_infra pull

	# update services
	docker-compose -f services/docker-compose.yml --project-name dev_services pull

}

create_network() {
    docker network create dev_infra_default || true
}

start_all () {
	# start infrastructure
	docker-compose -f infra/docker-compose.yml --project-name dev_infra up -d --build --remove-orphans

	# wait for gateway proxy (last service started before)
	echo "*****************************************************************"
	echo "******************* Stalling for Gateway Proxy ******************"
	echo "*****************************************************************"
	winpty docker run --rm --net=dev_infra_default -it mcandre/docker-wget --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 --tries 60 gateway-proxy:80/info

	# start services
	docker-compose -f services/docker-compose.yml --project-name dev_services up -d --build --remove-orphans

	echo "*****************************************************************"
	echo "********************* Stalling for services *********************"
	echo "*****************************************************************"
	winpty docker run --rm --net=dev_infra_default -it mcandre/docker-wget --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 --tries 30 frontend-service:8080
	winpty docker run --rm --net=dev_infra_default -it mcandre/docker-wget --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 --tries 30 identity-service:9096/info
}

# run infrastructure
if [[ "$1" = "infrastructure" ]]; then

	if [[ "$2" != "--no-updates" ]]; then
		update_images
	fi

	docker-compose -f infra/docker-compose.yml --project-name dev_infra up  -d  --build


elif [[ "$1" = "services" ]]; then

	if [[ "$2" != "--no-updates" ]]; then
		update_images
	fi

	# start services
	docker-compose -f services/docker-compose.yml \
		--project-name dev_services up \
		-d \
		--build \
        --force-recreate identity-service frontend-service frontend-service-sidecar indexing-service

elif [[ "$1" = "start" ]]; then

	update_images
	create_network
	start_all

elif [[ "$1" = "start-no-update" ]]; then

	start_all

elif [[ "$1" = "stop" ]]; then
	
	docker-compose -f services/docker-compose.yml --project-name dev_services stop
	docker-compose -f infra/docker-compose.yml --project-name dev_infra stop

elif [[ "$1" = "down" ]]; then

	read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
		docker-compose -f services/docker-compose.yml --project-name dev_services down --remove-orphans -v
		docker-compose -f infra/docker-compose.yml --project-name dev_infra down --remove-orphans -v
    fi

elif [[ "$1" = "stop-services" ]]; then
	
	docker-compose -f services/docker-compose.yml --project-name dev_services stop

elif [[ "$1" = "restart-single" ]]; then

	docker-compose -f services/docker-compose.yml --project-name dev_services up --build -d --force-recreate $2

	docker-compose -f services/docker-compose.yml \
		--project-name dev_services \
		logs -f $2

elif [[ "$1" = "services-logs" ]]; then
	
	docker-compose -f services/docker-compose.yml --project-name dev_services logs -f

elif [[ "$1" = "cloud-infra" ]]; then

	docker-compose -f infra/docker-compose.yml --project-name dev_infra up -d --build --force-recreate config-server service-discovery gateway-proxy
	docker-compose -f infra/docker-compose.yml --project-name dev_infra logs -f config-server service-discovery gateway-proxy

elif [[ "$1" = "keycloak" ]]; then

	docker-compose -f infra/docker-compose.yml --project-name dev_infra up -d --build --force-recreate keycloak
	docker-compose -f infra/docker-compose.yml --project-name dev_infra logs -f keycloak keycloak-db

elif [[ "$1" = "dev-infra" ]]; then

	docker-compose -f infra/docker-compose.yml --project-name dev_infra up -d --build --force-recreate kafka maildev solr dev-main-db
	docker-compose -f infra/docker-compose.yml --project-name dev_infra logs -f kafka maildev solr dev-main-db

elif [[ "$1" = "create-network" ]]; then
	create_network

else
    echo Usage: $0 COMMAND
    echo Commands:
    echo "  infrastructure          start only infrastructure components"
    echo "  services                start core services"
    echo "  start                   start infrastructure and core services"
    echo "  start-no-update         start infrastructure and core services, without updating the images"
    echo "  restart-single SERVICE  restart a single core service (e.g. identity-service)"
    echo "  stop                    stop infrastructure and core services"
    echo "  stop-services           stop core services, but leave infrastructure running"
    echo "  down                    stop and remove everything (incl. volumes)"
    echo "  services-logs           get the log output from the core services"
    exit 2
fi
