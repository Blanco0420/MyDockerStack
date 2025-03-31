#!/bin/bash

generate_password() {
    tr -dc 'A-Za-z0-9@!*.&%-' < /dev/urandom | head -c 32
}

if [ ! -f .env ]
then
    if [ -f .env.example ]
    then
        cp .env.example .env
    else
        echo "envexample not found Creating a new env file"
        touch .env
    fi
fi

declare -A credentials
credentials["INDEXER_USERNAME"]="admin"
credentials["INDEXER_PASSWORD"]="$(generate_password)"
credentials["API_USERNAME"]="wazuh-wui"
credentials["API_PASSWORD"]="$(generate_password)"
credentials["DASHBOARD_USERNAME"]="dashboarduser"
credentials["DASHBOARD_PASSWORD"]="$(generate_password)"

for key in "${!credentials[@]}"
do
    value="${credentials[$key]}"
    if grep -q "^$key=" .env
    then
        sed -i "s|^$key=.*|$key=$value|" .env
    else
        echo "$key=$value" >> .env
    fi
done
echo "Credentials have been generated and inserted into env"
echo "Setting up cert files..."
docker-compose -f generate-indexer-certs.yml run --rm generator

