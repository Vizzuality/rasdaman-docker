#!/bin/bash
export IMAGE_TAG=rasdaman-img
export CONTAINER_TAG=rasdaman-dev1

echo -e "Uninstallation tool for removing Rasdaman Docker image and container. WARNING: DATA OF THE CONTAINER WILL BE DELETED. \n"
read -p "Are you sure you want to continue now? Type y or n: " -n 1 -r REPLY
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

docker stop $CONTAINER_TAG
docker rm $CONTAINER_TAG
docker rmi $IMAGE_TAG
rm -R -f ~/docker.${CONTAINER_TAG}
