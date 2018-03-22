FROM centos:7

# Build arguments
ARG AMBARI_USER
ARG AMBARI_PASSWORD
ARG AMBARI_HOST

RUN yum update -y && yum install -y krb5-workstation wget which maven

COPY conf/krb5.conf /etc/krb5.conf

WORKDIR /tmp

# Set environment variables
ENV JAVA_HOME /usr/java/latest
ENV HDP_VERSION 2.6.4.0-91
ENV HADOOP_OPTS "-Dhdp.version=$HDP_VERSION $HADOOP_OPTS"
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop/
ENV YARN_CONF_DIR /opt/hadoop/etc/hadoop/
ENV TEZ_CONF_DIR /opt/tez/conf
ENV TEZ_JARS /opt/tez
ENV HADOOP_CLASSPATH ${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/* 

# Download components
# HADOOP
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

# JAVA
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.rpm"

# SPARK2
RUN wget http://mirror.nohup.it/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz

# HIVE
RUN wget https://archive.apache.org/dist/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz

# TEZ
RUN wget http://mirror.nohup.it/apache/tez/0.7.1/apache-tez-0.7.1-bin.tar.gz

# HBASE
RUN wget http://archive.apache.org/dist/hbase/1.1.2/hbase-1.1.2-bin.tar.gz

# OOZIE
RUN wget http://archive.apache.org/dist/oozie/4.3.1/oozie-4.3.1.tar.gz

# Install components
# HADOOP
RUN tar -xf /tmp/hadoop-2.7.3.tar.gz
RUN mv /tmp/hadoop-2.7.3 /opt/hadoop-2.7.3
RUN ln -s /opt/hadoop-2.7.3/ /opt/hadoop

# SPARK2
RUN tar -xf /tmp/spark-2.2.0-bin-hadoop2.7.tgz
RUN mv /tmp/spark-2.2.0-bin-hadoop2.7 /opt/spark-2.2.0-bin-hadoop2.7
RUN ln -s /opt/spark-2.2.0-bin-hadoop2.7 /opt/spark2
COPY conf/java-opts /opt/spark2/conf/java-opts

# JAVA
RUN yum localinstall -y jdk-8u161-linux-x64.rpm

# HIVE
RUN tar -xf /tmp/apache-hive-1.2.1-bin.tar.gz
RUN mv /tmp/apache-hive-1.2.1-bin /opt/apache-hive-1.2.1-bin
RUN ln -s /opt/apache-hive-1.2.1-bin /opt/hive

# TEZ
RUN tar -xf /tmp/apache-tez-0.7.1-bin.tar.gz
RUN mv /tmp/apache-tez-0.7.1-bin /opt/apache-tez-0.7.1-bin
RUN ln -s /opt/apache-tez-0.7.1-bin /opt/tez 

# HBASE
RUN tar -xf /tmp/hbase-1.1.2-bin.tar.gz
RUN mv /tmp/hbase-1.1.2 /opt/hbase-1.1.2
RUN ln -s /opt/hbase-1.1.2 /opt/hbase 

# OOZIE
RUN tar -xf /tmp/oozie-4.3.1.tar.gz
RUN /tmp/oozie-4.3.1/bin/mkdistro.sh -DskipTests -Dhadoop.version=2.7.3 -Dhive.version=1.2.1
RUN cp /tmp/oozie-4.3.1/client/target/oozie-client-4.3.1-client.tar.gz /tmp/oozie-client-4.3.1-client.tar.gz
RUN tar -xf /tmp/oozie-client-4.3.1-client.tar.gz
RUN mv /tmp/oozie-client-4.3.1 /opt/oozie-client-4.3.1
RUN ln -s /opt/oozie-client-4.3.1 /opt/oozie

# Download configurations
# WARNING: REPLACE BY REAL HOST

# HDFS
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HDFS/components/HDFS_CLIENT?format=client_config_tar -o hdfs-config.tar.gz
RUN tar -xf hdfs-config.tar.gz
RUN cp core-site.xml /opt/hadoop/etc/hadoop
RUN cp hdfs-site.xml /opt/hadoop/etc/hadoop
RUN mkdir /opt/hadoop/conf
COPY conf/topology_script.py /opt/hadoop/conf/topology_script.py

# YARN
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/YARN/components/YARN_CLIENT?format=client_config_tar -o yarn-config.tar.gz
RUN tar -xf yarn-config.tar.gz
RUN cp capacity-scheduler.xml /opt/hadoop/etc/hadoop
RUN cp yarn-site.xml /opt/hadoop/etc/hadoop

# MAPREDUCE2
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/MAPREDUCE2/components/MAPREDUCE2_CLIENT?format=client_config_tar -o mapred-config.tar.gz
RUN tar -xf mapred-config.tar.gz
RUN cp mapred-site.xml /opt/hadoop/etc/hadoop

# SPARK
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/SPARK2/components/SPARK2_CLIENT?format=client_config_tar -o spark-config.tar.gz
RUN tar -xf spark-config.tar.gz
RUN cp spark-defaults.conf /opt/spark2/conf
RUN wget http://central.maven.org/maven2/com/sun/jersey/jersey-bundle/1.9/jersey-bundle-1.9.jar
RUN cp jersey-bundle-1.9.jar /opt/spark2/jars
RUN echo "spark.driver.extraJavaOptions=-Dhdp.version=$HDP_VERSION" >> /opt/spark2/conf/spark-defaults.conf

# HIVE
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HIVE/components/HIVE_CLIENT?format=client_config_tar -o hive-config.tar.gz
RUN tar -xf hive-config.tar.gz
RUN cp hive-site.xml /opt/hive/conf/hive-site.xml

# TEZ 
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/TEZ/components/TEZ_CLIENT?format=client_config_tar -o tez-config.tar.gz
RUN tar -xf tez-config.tar.gz
RUN mkdir /opt/tez/conf
RUN cp tez-site.xml /opt/tez/conf/tez-site.xml

RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HBASE/components/HBASE_CLIENT?format=client_config_tar -o hbase-config.tar.gz
RUN tar -xf hbase-config.tar.gz
RUN cp hbase-site.xml /opt/hbase/conf/hbase-site.xml
RUN cp hbase-policy.xml /opt/hbase/conf/hbase-policy.xml

# HIVE aux libraries
# ATLAS
RUN mkdir /opt/hive-aux-libs
WORKDIR /opt/hive-aux-libs
RUN wget http://central.maven.org/maven2/org/apache/atlas/hive-bridge/0.8.2/hive-bridge-0.8.2.jar
RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-notification/0.8.2/atlas-notification-0.8.2.jar
RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-typesystem/0.8.2/atlas-typesystem-0.8.2.jar
RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-intg/0.8.2/atlas-intg-0.8.2.jar
RUN wget http://central.maven.org/maven2/org/apache/atlas/atlas-common/0.8.2/atlas-common-0.8.2.jar
ENV HIVE_AUX_JARS_PATH /opt/hive-aux-libs

# KAFKA
RUN wget http://central.maven.org/maven2/org/apache/kafka/kafka-clients/0.10.1.0/kafka-clients-0.10.1.0.jar

# ATLAS
WORKDIR /tmp
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/ATLAS/components/ATLAS_CLIENT?format=client_config_tar -o atlas-config.tar.gz
RUN tar -xf atlas-config.tar.gz
RUN cp application.properties /opt/hive/conf/atlas-application.properties

COPY conf/slaves /opt/hadoop/etc/hadoop

# BEELINE
WORKDIR /opt/hive-aux-libs
RUN wget http://central.maven.org/maven2/com/esotericsoftware/minlog/minlog/1.2/minlog-1.2.jar
RUN wget http://central.maven.org/maven2/org/objenesis/objenesis/1.2/objenesis-1.2.jar
RUN wget http://central.maven.org/maven2/com/esotericsoftware/reflectasm/reflectasm/1.07/reflectasm-1.07-shaded.jar

# Set PATH
ENV PATH $PATH:/opt/hadoop/bin:/opt/spark2/bin:/opt/hive/bin:/opt/hbase/bin:/opt/oozie/bin


RUN rm -rf /tmp/*
