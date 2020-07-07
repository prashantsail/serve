FROM ubuntu:18.04

ENV PYTHONUNBUFFERED TRUE

# Python 3.6.9
# pip 9.0.1 from /usr/lib/python3/dist-packages (python 3.6)
RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        python3 \
        python3-pip \
        python3-dev \
        python3-setuptools \
        python3-wheel \
        build-essential \
        openjdk-11-jdk \
        nodejs \
        npm

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

ENV PATH ~/.local/bin/:$PATH

# Install Torch Dependencies
RUN pip install --no-cache-dir \
        torch \
        torchvision \
        torchtext \
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

# Install API test dependencies
RUN npm install -g \
        newman \
        newman-reporter-html