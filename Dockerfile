FROM openshift/base-centos7

ARG LIBERTY_VERSION=18.0.0.1
ARG LIBERTY_SHA=a059c422c6ddd53276804b8e6f2ee0b00c97e1a7
ARG LIBERTY_URL=https://repo1.maven.org/maven2/io/openliberty/openliberty-runtime/$LIBERTY_VERSION/openliberty-runtime-$LIBERTY_VERSION.zip
ARG MAVEN_VERSION=3.5.2
ARG MAVEN_SHA=707b1f6e390a65bde4af4cdaf2a24d45fc19a6ded00fff02e91626e3e42ceaff
ARG MAVEN_BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries

ENV WLP_INSTALL_DIR /opt/ol/wlp
ENV MAVEN_HOME /usr/share/maven

### JDK setup ###
RUN yum update -y && \
    yum install -y wget && \
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all

### Maven setup ###
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

### Openliberty setup ###
RUN wget $LIBERTY_URL -q -O /tmp/wlp.zip \
   && echo "$LIBERTY_SHA  /tmp/wlp.zip" > /tmp/wlp.zip.sha1 \
   && sha1sum -c /tmp/wlp.zip.sha1 \
   && unzip -q /tmp/wlp.zip -d /opt/ol \
   && rm /tmp/wlp.zip \
   && rm /tmp/wlp.zip.sha1 \
   && $WLP_INSTALL_DIR/bin/server create \
   && mkdir $WLP_INSTALL_DIR/etc \
   && mkdir -p $WLP_INSTALL_DIR/usr/shared/resources \
   && rm -rf $WLP_INSTALL_DIR/output/.classCache /output/workarea

COPY ./etc/jvm.options $WLP_INSTALL_DIR/etc/
COPY ./etc/server.xml $WLP_INSTALL_DIR/usr/servers/defaultServer

### Openshift setup ###
LABEL io.k8s.description="Openliberty JavaEE container builder" \
      io.k8s.display-name="Openliberty 18.0.0.1" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,openliberty,javaee" \
      io.openshift.s2i.scripts-url=image:///usr/local/s2i

COPY ./s2i/bin/ /usr/local/s2i

EXPOSE 8080
CMD ["usage"]