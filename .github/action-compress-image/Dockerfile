FROM ubuntu:latest

RUN apt update; \
    apt install wget -y; \
    apt install imagemagick -y;

COPY entrypoint.sh /usr/local/bin/entrypoint

RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["/usr/local/bin/entrypoint"]