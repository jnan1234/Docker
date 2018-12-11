FROM tomcat:9.0.5-jre8

# Run the environment intense user $UID=9001& $GID=9001
ENV RUN_USER            intense -u 9001
ENV RUN_GROUP           intense -g 9001
RUN groupadd -r ${RUN_GROUP} && useradd -g ${RUN_GROUP} -d ${CATALINA_HOME} -s /bin/bash ${RUN_USER}
RUN chown -R intense:intense $CATALINA_HOME


# Add Binary files
ADD host-manager/context.xml /usr/local/tomcat/webapps/host-manager/META-INF/context.xml
ADD manager/context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
ADD tomcat-users.xml /usr/local/tomcat/conf/
ADD server.xml /usr/local/tomcat/conf/
ADD index.jsp /usr/local/tomcat/webapps/ROOT/

# remove unwanted files
RUN rm -rf /usr/local/tomcat/webapps/examples
RUN rm -rf /usr/local/tomcat/webapps/docs

# change the shutdown port
RUN sed -i 's/port="8005"/port="9005"/' /usr/local/tomcat/conf/server.xml

# remove the server banner
RUN sed -i 's/<Connector/<Connector Server=" " secure="true"/g' /usr/local/tomcat/conf/server.xml

# rename the manager and host-manager
RUN mv /usr/local/tomcat/webapps/manager /usr/local/tomcat/webapps/server
RUN mv /usr/local/tomcat/webapps/host-manager /usr/local/tomcat/webapps/host-server

# hide the server info
WORKDIR /usr/local/tomcat/lib
RUN mkdir -p org/apache/catalina/util
RUN unzip -j catalina.jar org/apache/catalina/util/ServerInfo.properties -d org/apache/catalina/util
RUN sed -i 's/server.info=.*/server.info=Hidden Network/g' org/apache/catalina/util/ServerInfo.properties

# password encryption
# RUN sed -i 's/resourceName/digest="md5" resourceName/g' ${CATALINA_HOME}/conf/server.xml
# RUN /usr/local/tomcat/bin/digest.sh -a "MD5" T0mc@t@1234

