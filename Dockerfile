FROM centos:7

# Build arguments
ARG AMBARI_USER
ARG AMBARI_PASSWORD
ARG AMBARI_HOST

RUN yum update -y && yum install -y krb5-workstation wget which maven vim

RUN wget -nv http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.4.0/hdp.repo -O /etc/yum.repos.d/hortonworks.repo
RUN yum install -y hadoop-client spark2 spark2-python hive-server2 hbase oozie-client kafka

COPY conf/krb5.conf /etc/krb5.conf

WORKDIR /tmp

# Set environment variables
ENV JAVA_HOME /usr/lib/jvm/java
ENV KAFKA_KERBEROS_PARAMS "-Djavax.security.auth.useSubjectCredsOnly=false -Djava.security.auth.login.config=/usr/hdp/current/kafka-broker/config/kafka_client_jaas.conf"
ENV HADOOP_CLASSPATH /usr/hdp/current/hbase-client/lib/*:/usr/hdp/current/hbase-client/conf/

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

## HIVE
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HIVE/components/HIVE_CLIENT?format=client_config_tar -o hive-config.tar.gz
RUN tar -xf hive-config.tar.gz
RUN cp hive-site.xml /usr/hdp/current/hive-client/conf
# ATLAS
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/ATLAS/components/ATLAS_CLIENT?format=client_config_tar -o atlas-config.tar.gz
RUN tar -xf atlas-config.tar.gz
RUN cp application.properties /usr/hdp/current/hive-client/conf

## TEZ
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/TEZ/components/TEZ_CLIENT?format=client_config_tar -o tez-config.tar.gz
RUN tar -xf tez-config.tar.gz
RUN cp tez-site.xml /usr/hdp/current/tez-client/conf

## HBASE
RUN curl --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -X GET http://$AMBARI_HOST/api/v1/clusters/EDI_test/services/HBASE/components/HBASE_CLIENT?format=client_config_tar -o hbase-config.tar.gz
RUN tar -xf hbase-config.tar.gz
RUN cp hbase-site.xml /usr/hdp/current/hbase-client/conf
RUN cp hbase-policy.xml /usr/hdp/current/hbase-client/conf

## KAFKA
COPY conf/kafka_jaas.conf /usr/hdp/current/kafka-broker/config/kafka_jaas.conf

# Clean /tmp
RUN rm -rf /tmp/*
