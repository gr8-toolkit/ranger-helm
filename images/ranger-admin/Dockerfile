ARG RANGER_VERSION=2.4.0
FROM armadik/ranger-builds:$RANGER_VERSION as base

FROM ubuntu:22.04
COPY --from=base /opt/ranger /opt/ranger-src

ARG RANGER_VERSION=2.4.0
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk lsb-release bc wget vim curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ranger

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

RUN tar -zxf /opt/ranger-src/target/ranger-$RANGER_VERSION-admin.tar.gz -C /opt/  && \
    ln -s /opt/ranger-$RANGER_VERSION-admin /opt/ranger-admin && \
    rm -rf /opt/ranger-src/target/*

RUN wget -q https://jdbc.postgresql.org/download/postgresql-42.2.12.jar -O /usr/share/java/postgresql-connector-java.jar && \
    chmod 644 /usr/share/java/postgresql-connector-java.jar

RUN wget -q https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar  -O /usr/share/java/jmx_prometheus_javaagent.jar && \
    chmod 644 /usr/share/java/jmx_prometheus_javaagent.jar
RUN echo "{}" > /opt/ranger-admin/jmx_prometheus_javaagent.yaml

RUN mkdir -p /opt/ranger-admin/jisql/lib/
COPY jopt-simple-3.2.jar /opt/ranger-admin/jisql/lib/
COPY jisql-2.4.0.jar /opt/ranger-admin/jisql/lib/
COPY bootstrap.sh /opt/ranger-admin/
RUN chmod +x /opt/ranger-admin/bootstrap.sh

#RUN chown -R ranger:ranger /opt/

EXPOSE 6080

ENV RANGER_ADMIN_CONF=/opt/ranger-admin
ENV RANGER_USER=ranger
ENV RANGER_HOME=/opt/ranger-admin

WORKDIR /opt/ranger-admin/

ENTRYPOINT ["/opt/ranger-admin/bootstrap.sh"]
