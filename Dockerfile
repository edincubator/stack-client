FROM centos:7

# Build arguments
ARG AMBARI_USER
ARG AMBARI_PASSWORD
ARG AMBARI_HOST

RUN yum update -y && yum install -y krb5-workstation wget which maven vim

RUN wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.4.0/hdp.repo -O /etc/yum.repos.d/hortonworks.repo
RUN yum install -y hadoop-client spark2 hive-server2 hbase oozie-client kafka

COPY conf/krb5.conf /etc/krb5.conf

WORKDIR /tmp

# Set environment variables
ENV JAVA_HOME /usr/lib/jvm/java
ENV KAFKA_KERBEROS_PARAMS "-Djavax.security.auth.useSubjectCredsOnly=false -Djava.security.auth.login.config=/usr/hdp/current/kafka-broker/config/kafka_jaas.conf"
# ENV HDP_VERSION 2.6.4.0-91
# ENV HADOOP_OPTS "-Dhdp.version=$HDP_VERSION $HADOOP_OPTS"
# ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop/
# ENV YARN_CONF_DIR /opt/hadoop/etc/hadoop/
# ENV TEZ_CONF_DIR /opt/tez/conf
# ENV TEZ_JARS /opt/tez
# ENV HADOOP_CLASSPATH ${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*

# Configure
## HDFS
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HDFS/components/HDFS_CLIENT?format=client_config_tar -o hdfs-config.tar.gz
RUN tar -xf hdfs-config.tar.gz
RUN cp core-site.xml /usr/hdp/current/hadoop-client/conf
RUN cp hdfs-site.xml /usr/hdp/current/hadoop-client/conf
COPY conf/topology_script.py /usr/hdp/current/hadoop-client/conf
COPY conf/slaves /usr/hdp/current/hadoop-client/conf

## YARN
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/YARN/components/YARN_CLIENT?format=client_config_tar -o yarn-config.tar.gz
RUN tar -xf yarn-config.tar.gz
RUN cp capacity-scheduler.xml /usr/hdp/current/hadoop-client/conf
RUN cp yarn-site.xml /usr/hdp/current/hadoop-client/conf

## MR2
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/MAPREDUCE2/components/MAPREDUCE2_CLIENT?format=client_config_tar -o mapred-config.tar.gz
RUN tar -xf mapred-config.tar.gz
RUN cp mapred-site.xml /usr/hdp/current/hadoop-client/conf

## SPARK2
# COPY conf/java-opts /opt/spark2/conf/java-opts
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/SPARK2/components/SPARK2_CLIENT?format=client_config_tar -o spark-config.tar.gz
RUN tar -xf spark-config.tar.gz
RUN cp spark-defaults.conf /usr/hdp/current/spark2-client/conf
# RUN wget http://central.maven.org/maven2/com/sun/jersey/jersey-bundle/1.9/jersey-bundle-1.9.jar
# RUN cp jersey-bundle-1.9.jar /opt/spark2/jars
# RUN echo "spark.driver.extraJavaOptions=-Dhdp.version=$HDP_VERSION" >> /opt/spark2/conf/spark-defaults.conf

## HIVE
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HIVE/components/HIVE_CLIENT?format=client_config_tar -o hive-config.tar.gz
RUN tar -xf hive-config.tar.gz
RUN cp hive-site.xml /usr/hdp/current/hive-client/conf
# ATLAS
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/ATLAS/components/ATLAS_CLIENT?format=client_config_tar -o atlas-config.tar.gz
RUN tar -xf atlas-config.tar.gz
RUN cp application.properties /usr/hdp/current/hive-client/conf
# # Aux libraries
# # Atlas
# RUN mkdir /opt/hive-aux-libs
# WORKDIR /opt/hive-aux-libs
# RUN wget http://central.maven.org/maven2/org/apache/atlas/hive-bridge/0.8.2/hive-bridge-0.8.2.jar
# RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-notification/0.8.2/atlas-notification-0.8.2.jar
# RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-typesystem/0.8.2/atlas-typesystem-0.8.2.jar
# RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-intg/0.8.2/atlas-intg-0.8.2.jar
# RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-common/0.8.2/atlas-common-0.8.2.jar
# ENV HIVE_AUX_JARS_PATH /opt/hive-aux-libs
# # Beeline
# WORKDIR /opt/hive-aux-libs
# RUN wget http://central.maven.org/maven2/com/esotericsoftware/minlog/minlog/1.2/minlog-1.2.jar
# RUN wget http://central.maven.org/maven2/org/objenesis/objenesis/1.2/objenesis-1.2.jar
# RUN wget http://central.maven.org/maven2/com/esotericsoftware/reflectasm/reflectasm/1.07/reflectasm-1.07-shaded.jar

## TEZ
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/TEZ/components/TEZ_CLIENT?format=client_config_tar -o tez-config.tar.gz
RUN tar -xf tez-config.tar.gz
RUN cp tez-site.xml /usr/hdp/current/tez-client/conf

## HBASE
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HBASE/components/HBASE_CLIENT?format=client_config_tar -o hbase-config.tar.gz
RUN tar -xf hbase-config.tar.gz
RUN cp hbase-site.xml /usr/hdp/current/hbase-client/conf
RUN cp hbase-policy.xml /usr/hdp/current/hbase-client/conf

## OOZIE

## PIG

## KAFKA
COPY conf/kafka_jaas.conf /usr/hdp/current/kafka-broker/config/kafka_jaas.conf

# Set PATH
# ENV PATH $PATH:/opt/hadoop/bin:/opt/spark2/bin:/opt/hive/bin:/opt/hbase/bin:/opt/oozie/bin:/opt/pig/bin:/usr/hdp/current/kafka-broker/bin

# Clean /tmp
RUN rm -rf /tmp/*
