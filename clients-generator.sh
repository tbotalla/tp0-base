#!/bin/bash

#######################################
# Error handling
#######################################
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

clean() {
  echo "Error occurred"
  rm new_client_segment.txt 2> /dev/null || true
}

trap clean ERR

#######################################
# Main logic
#######################################
if [ "$#" -ne 1 ]; then
    echo "Invalid parameters. Usage example: clients-generator.sh 3"
    exit 1
fi

echo "Starting clients-generator.sh script..."
num_clients=$1
pwd=$(pwd)

validate_clients_number() {
  clients=$1
  regex_only_numbers='^[0-9]+$'
  if ! [[ $clients =~ $regex_only_numbers ]]; then
    echo "Error: the parameter ""$clients"" is not a number" >&2
    exit 1
  fi
}

execute() {
  clients=$1
  echo "Requested number of clients: $clients"
  base_docker_compose_file=$pwd/"base-docker-compose-dev.yaml"
  target_docker_compose_file=$pwd/"docker-compose-dev.yaml"

  echo "Creating new file: $target_docker_compose_file"
  cp "$base_docker_compose_file" "$target_docker_compose_file"

  echo "Copying new client section from $base_docker_compose_file"
  client_segment=$(sed -n '16,31p' "$base_docker_compose_file")
  echo "$client_segment" >new_client_segment.txt

  echo "Deleting original client section from $target_docker_compose_file"
  sed -i '17,31d' "$target_docker_compose_file"

  for ((i = clients; i >= 1; i--)); do
    sed -i '/services:/r new_client_segment.txt' "$target_docker_compose_file"
    sed -i "s/client1:/client""$i"":/g" "$target_docker_compose_file"
    sed -i "s/CLI_ID=1/CLI_ID=""$i""/g" "$target_docker_compose_file"
    sed -i "s/container_name: client1/container_name: client""$i""/g" "$target_docker_compose_file"
  done

  rm new_client_segment.txt

  echo "Successfully created all clients"
}

validate_clients_number "$num_clients"
execute "$num_clients"