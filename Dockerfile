# syntax=docker/dockerfile:1

# This is our first build stage, it will not persist in the final image
FROM ubuntu as intermediate
RUN apt-get update && apt-get install -y --no-install-recommends git openssh-client && rm -rf /var/lib/apt/lists/*
RUN mkdir -p -m 0700 /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts
# Download the computer vision framework
RUN --mount=type=ssh git clone git@github.com:pcr-upm/images_framework.git images_framework

# Copy the repository from the previous image
FROM ubuntu
ENV LANG=C.UTF-8
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y --no-install-recommends build-essential wget libsm6 libxext6 libxrender-dev libglib2.0-0
RUN mkdir -p /home/username
WORKDIR /home/username
COPY --from=intermediate /images_framework /home/username/images_framework
LABEL maintainer="roberto.valle@upm.es"
# Setup conda environment
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/username/miniconda.sh
RUN chmod +x /home/username/miniconda.sh
RUN /home/username/miniconda.sh -b -p /home/username/conda
RUN /home/username/conda/bin/conda create --name framework python=3.6
# Activate conda environment
ENV PATH /home/username/conda/envs/framework/bin:/home/username/conda/bin:$PATH
# Make RUN commands use the new environment (source activate framework)
SHELL ["conda", "run", "-n", "framework", "/bin/bash", "-c"]
# Install dependencies
RUN pip install numpy scipy opencv-python opencv-contrib-python rasterio pillow pascal-voc-writer
RUN conda install -c conda-forge gdal
