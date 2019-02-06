# TemplateFx Server - Dockerfile
# Copyright (c) 2011-2019 Chris Mason <chris@templatefx.org>
# 
# This Dockerfile will containerise the TemplateFx Server with a minimised version of OpenJDK 11 and 
# start it running on port TCP/8080 on localhost waiting for connections (preferably via Apache using ProxyPass).
#
# Docker Build and Run:
#  docker image build -t templatefx:latest .
#  docker container run -d --name templatefx --restart unless-stopped -p 127.0.0.1:8080:8080 templatefx:latest

FROM adoptopenjdk/openjdk11:latest AS build

RUN jlink \
 --add-modules java.base,java.management,java.naming,java.scripting,jdk.httpserver,jdk.scripting.nashorn,jdk.naming.dns \
 --strip-debug \
 --compress=2 \
 --no-header-files \
 --no-man-pages \
 --output /tmp/java

WORKDIR /tmp

RUN apt-get update
RUN apt-get install -y --no-install-recommends wget

RUN curl -s https://api.github.com/repos/chrixm/templatefx/releases/latest | \
 grep "browser_download_url.*TemplateFx_Server_v.*.tar.gz" | cut -d\" -f4 | wget -qi - && \
 for f in TemplateFx_Server_v*.tar.gz; do tar xzf "$f"; done && \
 rm TemplateFx_Server_v*.tar.gz


FROM debian:stretch-slim

MAINTAINER Chris Mason <chris@templatefx.org>

WORKDIR /tmp

COPY --from=build /tmp/java /opt/java
COPY --from=build /tmp/TFxServer.jar .

ENV JAVA_HOME "/opt/java"
ENV PATH "$PATH:$JAVA_HOME/bin"

EXPOSE 8080

CMD [ "java", "-Dnashorn.args=--no-deprecation-warning", "-jar", "TFxServer.jar", "-s", "0.0.0.0:8080" ]
