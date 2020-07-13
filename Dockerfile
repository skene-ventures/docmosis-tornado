ARG fromTag=latest
ARG imageRepo=alpine

FROM ${imageRepo}:${fromTag}

ARG DOCMOSIS_VERSION=2.7.3_8366
ARG DOCMOSIS_SHA256SUM=522aa7cfc5323ba0316589061ab21462b53252337da8dd69ac52ee4f5a6a40cb
ARG JAVA_VERSION=8

RUN apk add --no-cache \
    libreoffice \
    openjdk${JAVA_VERSION} \
    && apk add --no-cache --virtual .build-deps \
    msttcorefonts-installer \
    fontconfig \
    && update-ms-fonts \
    && fc-cache -f \
    && apk del --no-cache .build-deps \
    && addgroup docmosis \
    && adduser docmosis -G docmosis -D -s /bin/false

WORKDIR /home/docmosis

RUN DOCMOSIS_VERSION_SHORT=$(echo $DOCMOSIS_VERSION | cut -f1 -d_) \
    && echo "${DOCMOSIS_SHA256SUM}  docmosisTornado${DOCMOSIS_VERSION}.zip" > SHA256SUMS \
    && echo "Downloading Docmosis Tornado ${DOCMOSIS_VERSION}..." \
    && wget -q https://resources.docmosis.com/Downloads/Tornado/${DOCMOSIS_VERSION_SHORT}/docmosisTornado${DOCMOSIS_VERSION}.zip \
    && sha256sum -c SHA256SUMS \
    && unzip docmosisTornado${DOCMOSIS_VERSION}.zip docmosisTornado*.war docs/* licenses/* \
    && mv docmosisTornado*.war docmosisTornado.war \
    && rm -f docmosisTornado${DOCMOSIS_VERSION}.zip

RUN printf '%s\n' \
    "log4j.rootCategory=LOG4J_LOGLEVEL, A1" \
    "log4j.appender.A1=org.apache.log4j.ConsoleAppender" \
    "log4j.appender.A1.layout=org.apache.log4j.PatternLayout" \
    "log4j.appender.A1.layout.ConversionPattern=%d{DATE} [%t] %-5p %c{1} - %m%n" \
    > /home/docmosis/log4j.properties \
    && printf '%s\n' \
    "sed -i \"s/LOG4J_LOGLEVEL/\${LOG4J_LOGLEVEL}/1\" /home/docmosis/log4j.properties" \
    "java -Ddocmosis.tornado.render.useUrl=\${DOCMOSIS_RENDER_USEURL} -jar docmosisTornado.war" \
    > /home/docmosis/run.sh

USER docmosis
RUN mkdir /home/docmosis/templates /home/docmosis/working

ENV DOCMOSIS_TEMPLATESDIR=templates \
    DOCMOSIS_WORKINGDIR=working \
    DOCMOSIS_LOG4J_CONFIG_FILE=log4j.properties \
    DOCMOSIS_RENDER_USEURL=http://localhost:8080/ \
    LOG4J_LOGLEVEL=INFO \
    JAVA_TOOL_OPTIONS="-XX:InitialRAMPercentage=20.0 -XX:MaxRAMPercentage=65.0 -XX:MinRAMPercentage=10.0 -XX:+UseParallelOldGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Xms128M"

ARG IMAGE_NAME=skeneventures/docmosis-tornado:latest

LABEL maintainer="Martyn Skene Ashworth <martyn@skven.io>" \
    readme.md="https://github.com/skene-ventures/docmosis-tornado/blob/master/README.md" \
    description="This Dockerfile will install the ${DOCMOSIS_VERSION} version of Docmosis Tornado." \
    org.label-schema.usage="https://github.com/skene-ventures/docmosis-tornado/blob/master/README.md#Instructions" \
    org.label-schema.url="https://github.com/skene-ventures/docmosis-tornado/blob/master/README.md" \
    org.label-schema.name="Tornado" \
    org.label-schema.vendor="Docmosis" \
    org.label-schema.version=${DOCMOSIS_VERSION} \
    org.label-schema.schema-version="1.0" \
    org.label-schema.docker.cmd="docker run ${IMAGE_NAME}"

EXPOSE 8080
VOLUME /home/docmosis/templates

CMD /bin/sh /home/docmosis/run.sh