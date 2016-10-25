#!/bin/bash

hash docker 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker is not installed"
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
my_name="${my_dir##*/}"

# This builds the tester image
app_dir=/app
${my_dir}/client/build-image.sh ${app_dir}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

docker_version=$(docker --version | awk '{print $3}' | sed '$s/.$//')
client_port=4568
server_port=4567

#cat ${my_dir}/docker-compose.yml.PORT |
#  sed "s/DOCKER_ENGINE_VERSION/${docker_version}/g" |
#  sed "s/SERVER_PORT/${server_port}/g" |
#  sed "s/CLIENT_PORT/${client_port}/g" > ${my_dir}/docker-compose.yml

docker-compose down
docker-compose up -d

# - - - - - - - - - - - - - - - - - - - - - - - - - -

client_cid=`docker ps --all --quiet --filter "name=csharp-nunit-tester"`
docker exec ${client_cid} sh -c "/app/src/run_tests.sh"
client_status=$?

# - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ ${client_status} != 0 ]; then
  echo
  echo "client: cid = ${client_cid}, status = ${client_status}"
  echo
  exit 1
else
  echo
  echo "All passed. Removing containers..."
  docker-compose down 2>/dev/null
  exit 0
fi
