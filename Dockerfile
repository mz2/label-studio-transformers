FROM nvcr.io/nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

COPY --from=continuumio/miniconda3:22.11.1 /opt/conda /opt/conda

ENV PATH=/opt/conda/bin:$PATH

# Usage examples
RUN set -ex && \
    conda config --set always_yes yes --set changeps1 no && \
    conda info -a && \
    conda config --add channels conda-forge && \
    conda install --quiet --freeze-installed -c main conda-pack

RUN pip3 install packaging==21.3
RUN conda install torchmetrics==0.7.3 -c pytorch -c conda-forge

RUN conda install -c pytorch-lts pytorch

RUN apt-get update && apt-get install -y \
    cmake \
    rustc \
    cargo \
    git \
    ca-certificates \
    wget \
    curl \
    python3 \
    python3-py \
    python3-dev \
    python3-pip \
    python3-numpy \
    python3-pytest \
    python3-setuptools \
    python3-wheel \

RUN python3 -m pip install --upgrade pip setuptools wheel
RUN pip3 install pyyaml typing-extensions

WORKDIR /label-studio-ml
COPY . /label-studio-ml

RUN pip3 install -r requirements.txt

RUN label-studio-ml init ner-backend --script ./models/ner.py
RUN cp models/utils.py ner-backend/utils.py

CMD label-studio-ml start ner-backend
