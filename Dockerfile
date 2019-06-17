# TemplateFx Server - Dockerfile
# Copyright (c) 2011-2019 Chris Mason <chris@templatefx.org>
#
# This Dockerfile will containerise the TemplateFx Server with a minimised version of OpenJDK 11 and 
# start it running on port TCP/8080 on localhost waiting for connections (preferably via Apache using ProxyPass).
#
# Docker Build and Run:
#  docker image build -t templatefx:latest https://github.com/chrixm/templatefx/raw/master/Dockerfile
#  docker container run -d --name templatefx --restart unless-stopped -e TZ=Europe/London -p 127.0.0.1:8080:8080 templatefx:latest

FROM adoptopenjdk/openjdk11:latest AS build

RUN jlink \
--add-modules java.base,java.management,java.naming,java.scripting,jdk.httpserver,jdk.scripting.nashorn,jdk.naming.dns \
--strip-debug \
--compress=2 \
--no-header-files \
--no-man-pages \
--output /tmp/java

RUN curl -s https://api.github.com/repos/chrixm/templatefx/releases/latest \
| grep "browser_download_url.*TemplateFx_Server_v.*.tar.gz" \
| cut -d'"' -f4 \
| xargs -I {} curl -sL {} \
| tar -zx -C /tmp


FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

MAINTAINER Chris Mason <chris@templatefx.org>

COPY --from=build /tmp/java /opt/java
COPY --from=build /tmp/TFxServer.jar /opt/templatefx/

EXPOSE 8080

CMD [ "/opt/java/bin/java", "-Dnashorn.args=--no-deprecation-warning", "-jar", "/opt/templatefx/TFxServer.jar", "-s", "0.0.0.0:8080" ]
