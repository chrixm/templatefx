# Dockerfile for TemplateFx Server
# Copyright (c) 2011-2019 Chris Mason <chris@templatefx.org>

FROM adoptopenjdk/openjdk11:latest AS build

RUN jlink \
--add-modules java.base,java.management,java.naming,java.scripting,jdk.httpserver,jdk.scripting.nashorn,jdk.naming.dns,jdk.crypto.ec \
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

COPY --chown=nobody:nobody --from=build /tmp/java /opt/java
COPY --chown=nobody:nobody --from=build /tmp/TFxServer.jar /opt/templatefx/

USER nobody

EXPOSE 8080

CMD [ "/opt/java/bin/java", "-Dnashorn.args=--no-deprecation-warning", "-jar", "/opt/templatefx/TFxServer.jar", "-s", "0.0.0.0" ]
