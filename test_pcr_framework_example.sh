#!/bin/bash
echo 'Using Docker to start the container and run tests ...'
sudo docker build --force-rm --ssh default=$HOME/.ssh/id_rsa -t pcr_framework_image .
sudo docker run --name pcr_framework_container --rm --gpus all -it -d pcr_framework_image bash
sudo docker exec -w /home/username/ pcr_framework_container python pcr_framework/test/pcr_framework_test.py
echo 'Transferring data from docker container to your local machine ...'
mkdir -p output
sudo docker cp pcr_framework_container:/home/username/pcr_framework/output/images/. output/
sudo chown -R "${USER}":"${USER}" output
sudo docker rm -f pcr_framework_container
sudo docker image rm pcr_framework_image
sudo docker builder prune -a -f