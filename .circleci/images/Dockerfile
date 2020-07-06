FROM ubuntu:18.04

ENV PYTHONUNBUFFERED TRUE

RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        python3
        python3-pip
        openjdk-11-jdk

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN update-alternatives --install /usr/local/bin/pip pip /usr/local/bin/pip3 1

# Install Torch Dependencies
RUN pip install \
        torch \
        torchvision \
        torchtext \
        torchvision \
        sentencepiece \
        psutil \
        future

# Install Pytest Dependencies
RUN pip install \
        mock \
        pytest \
        pylint==2.4.4 \
        pytest-mock \
        pytest-cov