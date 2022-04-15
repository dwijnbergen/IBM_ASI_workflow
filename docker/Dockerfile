FROM rocker/r-ver:4.0.5-cuda11.1
ADD ./R_4.0_packages.gz /usr/local/lib/R/library
RUN apt update && apt install \
    libxml2=2.9.10+dfsg-5