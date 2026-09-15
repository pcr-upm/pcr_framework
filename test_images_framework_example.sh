#!/bin/bash
echo 'Using Docker to start the container and run tests ...'
sudo docker build --force-rm --ssh default=$HOME/.ssh/id_rsa -t images_framework_image .
sudo docker run --name images_framework_container --rm --gpus all -it -d images_framework_image bash
sudo docker exec -w /home/username/ images_framework_container python images_framework/test/images_framework_test.py
echo 'Transferring data from docker container to your local machine ...'
mkdir -p output
sudo docker cp images_framework_container:/home/username/conda/envs/images_framework/lib/python3.6/site-packages/images_framework/output/images/. output/
sudo chown -R "${USER}":"${USER}" output
sudo docker rm -f images_framework_container
sudo docker image rm images_framework_image
sudo docker builder prune -a -f