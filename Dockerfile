# Specifiying the os that we're going to run our image
FROM centos:7

# updating the yum repository in order to install the necessary packages to run eap 
# Creating a group named 'jboss' with guid 1000
# Creating a user jboss that belong to this groupe of users with the uid 1000 and operate on the /opt/jboss directory. Also the user must be protected
# from any third party that want to login to our image container that's why we made him part of the /sbin/nologin that doesn't allow ssh 
# connections and the normal ways of login into a user. We change the directory permissions to prohibit other users or users from the same group except 
# for root to not execute 
RUN yum update -y && \
    yum -y install xmlstarlet saxon augeas bsdtar unzip && \
    groupadd -r jboss -g 1000 && \
    useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss
#Specifying the working directory 
WORKDIR /opt/jboss

# Switching to the root user in order to install the next layer of packages and construct our image
USER root

# Installing openjdk which is a necessary package for wildfly to run 
RUN yum -y install java-1.7.0-openjdk-devel && yum clean all

#Specifying the environment variables 
ENV JAVA_HOME /usr/lib/jvm/java
ENV WILDFLY_VERSION 26.1.1.Final

# Installing the pakcages necessary to run wildfly images
RUN cd /opt/jboss && \
    curl -L -O https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz && \
    tar -xvzf wildfly-${WILDFLY_VERSION}.tar.gz && \
    mv /opt/jboss/wildfly-${WILDFLY_VERSION} /opt/jboss/wildfly && \
    rm wildfly-${WILDFLY_VERSION}.tar.gz 

ENV JBOSS_HOME /opt/jboss/wildfly

# Switching to the jboss user to avoid security issues
USER jboss

EXPOSE 8000

# wildfly had two mode of 
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-c", "standalone-full.xml", "-b", "0.0.0.0"]