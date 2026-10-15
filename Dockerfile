# syntax=docker/dockerfile:1
# =====================================================================
#  MediBook in one container: build with Maven, run on Tomcat 9.
#
#  Two stages. The first one needs a JDK and Maven, the second one only a
#  JRE, so the image that actually runs stays small.
#
#  Render builds this file by itself on every deploy. You need Docker
#  locally only if you want to try the same image on your own machine:
#      docker build -t medibook .
#      docker run -p 8080:8080 -e DB_URL=... -e DB_USER=... -e DB_PASSWORD=... medibook
#
#  The database is never part of this image. It is a hosted MySQL or TiDB
#  cluster, and the three settings are written at container start by
#  docker/entrypoint.sh, so no password is baked into a layer or a commit.
# =====================================================================

# ---------------------------------------------------------------- stage 1
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# pom first: the dependency download is the slow part, and this layer is
# reused as long as pom.xml does not change
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline || true

COPY src ./src
RUN mvn -B -DskipTests clean package

# ---------------------------------------------------------------- stage 2
FROM tomcat:9.0-jre17-temurin-noble

# 512 MB is the whole machine on Render's free instance, and Tomcat is not the
# only process in it, so the heap is capped well below that. Serial GC uses the
# least memory of the JVM collectors, which matters more here than throughput.
ENV CATALINA_OPTS="-Xmx256m -XX:MaxMetaspaceSize=128m -Xss256k -XX:+UseSerialGC -Dfile.encoding=UTF-8"

# drop the ROOT, manager and docs applications that ship with Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# the exploded web application, not the war file: the entrypoint rewrites
# WEB-INF/classes/db.properties at start, and Tomcat would unpack a war over
# that change on every boot. Maven leaves the same layout in target/medibook.
COPY --from=build /workspace/target/medibook /usr/local/tomcat/webapps/ROOT

COPY docker/entrypoint.sh /usr/local/bin/medibook-entrypoint.sh
RUN chmod +x /usr/local/bin/medibook-entrypoint.sh

# Tomcat's own default, and the port this app listens on unless PORT is set
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/medibook-entrypoint.sh"]
