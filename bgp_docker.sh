#!/bin/bash

# Adapted from the Docker script we use in CS2110, but for a new image with bgpstream and pybgpstream pre-built.

release="3.3"
imageBaseName="galovadia03/bgpstream"
imageName="${imageBaseName}:${release}"

define() { IFS=$'\n' read -r -d '' "${1}" || true; }

description="Run the Docker container"

usage_text="Run the script with ./bgp_docker.sh"
define usage_text <<'EOF'
USAGE:
    ./bgp_docker.sh [start|stop|-h|--help]

OPTIONS:
    start
            Start a new nongraphical container in the background. This is the default if no options
            are provided.
    stop
            Stop and remove any running instances of the container.
    -h, --help
            Show this help text.
EOF

print_help() {
  >&2 echo -e "$description\n\n$usage_text"
} 

print_usage() {
  >&2 echo "$usage_text"
}

action=""
if [ $# -eq 0 ]; then
  action="start"
elif [ $# -eq 1 ]; then
  case "$1" in
    start)
      action="start"
      ;;
    stop)
      action="stop"
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      >&2 echo "Error: unrecognized argument: $1"
      >&2 echo ""
      print_usage
      exit 1
      ;;
  esac
elif [ $# -gt 1 ]; then
  >&2 echo "Error: too many arguments"
  >&2 echo ""
  print_usage
  exit 1
fi

if ! docker -v >/dev/null; then
  >&2 echo "ERROR: Docker not found. Please install Docker before running this script."
  exit 1
fi

if ! docker container ls >/dev/null; then
  >&2 echo "ERROR: Docker is not currently running. Please start Docker before running this script."
  exit 1
fi

echo "Found Docker Installation"

if [ "$action" = "stop" ]; then
  existingContainers=($(docker ps -a | grep "$imageBaseName" | awk '{print $1}'))
  echo "${existingContainers[@]}"
  if [ "${#existingContainers[@]}" -ne 0 ]; then
    echo "Found CS 2110 containers. Stopping and removing them."
    docker stop "${existingContainers[@]}" >/dev/null
    docker rm "${existingContainers[@]}" >/dev/null
  else
    echo "No existing containers."
  fi

  echo "Successfully stopped containers"
  exit 0
fi

echo "Pulling down most recent image of $imageName"

if ! docker pull $imageName; then
  >&2 echo "ERROR: Unable to pull down the most recent image of $imageName"
fi

echo "Starting up new Docker Container:"

if command -v docker-machine &> /dev/null; then
  # We're on legacy Docker Toolbox
  # pwd -W doesn't work with Docker Toolbox
  # Extra '/' fixes some mounting issues
  currDir="/$(pwd)"
else
  # pwd -W should correct path incompatibilites on Windows for Docker Desktop users
  currDir="/$(pwd -W 2>/dev/null || pwd)"
fi

if [ "$action" = "start" ]; then
  docker run --rm -v "$currDir":/usr/src/app/local/ --cap-add=SYS_PTRACE -w /usr/src/app/local --security-opt seccomp=unconfined -it "$imageName"
fi

