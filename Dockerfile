FROM openjdk:8-jre-alpine

# Install Java JAI libraries
RUN \
    apk add --no-cache ca-certificates curl && \
    cd /tmp && \
    curl -L http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz | tar xfz - && \
    curl -L http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz  | tar xfz - && \
    mv /tmp/jai*/lib/*.jar $JAVA_HOME/jre/lib/ext/  && \
    mv /tmp/jai*/lib/*.so $JAVA_HOME/jre/lib/amd64/  && \
    rm -r /tmp/*
    
# Install geoserver
ARG GS_VERSION=2.13.0
ENV GEOSERVER_HOME /geoserver
RUN \
    mkdir -p /geoserver && \
    curl -L http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/geoserver-${GS_VERSION}-bin.zip > /tmp/geoserver.zip && \
    unzip /tmp/geoserver.zip -d / && \
    mv $GEOSERVER_HOME/geoserver-$GS_VERSION $GEOSERVER_HOME && \
    chgrp -R 0 $GEOSERVER_HOME && \
    chmod -R g+rwX $GEOSERVER_HOME && \
    cd $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib  && \
    rm jai_core-*jar jai_imageio-*.jar jai_codec-*.jar  && \
    apk del curl  && \
    rm -r /tmp/* 
    
ENV JAVA_OPTS "-server -Xms256m -Xmx768m"
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 

CMD /entrypoint.sh
