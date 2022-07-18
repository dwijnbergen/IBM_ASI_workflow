FROM rocker/r-ver:4.0.5-cuda11.1
ADD ./R_4.0_packages.gz /usr/local/lib/R/library
RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
RUN apt update
RUN apt install -y \
    libxml2=2.9.10+dfsg-5 \
    default-jre
