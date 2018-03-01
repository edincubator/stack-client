FROM centos:7

# Build arguments
ARG AMBARI_USER
ARG AMBARI_PASSWORD
ARG AMBARI_HOST

RUN yum update -y && yum install -y krb5-workstation wget which

COPY conf/krb5.conf /etc/krb5.conf

WORKDIR /tmp

# Set environment variables
ENV PATH $PATH:/opt/hadoop/bin:/opt/spark/bin
ENV JAVA_HOME /usr/java/latest
ENV HDP_VERSION 2.6.4.0-91
ENV HADOOP_OPTS "-Dhdp.version=$HDP_VERSION $HADOOP_OPTS"
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop/
ENV YARN_CONF_DIR /opt/hadoop/etc/hadoop/

# Download components
# HADOOP
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

# JAVA
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.rpm"

# SPARK
RUN wget http://mirror.nohup.it/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz

# Install components
# HADOOP
RUN tar -xf /tmp/hadoop-2.7.3.tar.gz
RUN mv /tmp/hadoop-2.7.3 /opt/hadoop-2.7.3
RUN ln -s /opt/hadoop-2.7.3/ /opt/hadoop

# SPARK
RUN tar -xf /tmp/spark-2.2.0-bin-hadoop2.7.tgz
RUN mv /tmp/spark-2.2.0-bin-hadoop2.7 /opt/spark-2.2.0-bin-hadoop2.7
RUN ln -s /opt/spark-2.2.0-bin-hadoop2.7 /opt/spark 
COPY conf/java-opts /opt/spark/conf/java-opts

# JAVA
RUN yum localinstall -y jdk-8u161-linux-x64.rpm

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
RUN cp spark-defaults.conf /opt/spark/conf
RUN wget http://central.maven.org/maven2/com/sun/jersey/jersey-bundle/1.9/jersey-bundle-1.9.jar
RUN cp jersey-bundle-1.9.jar /opt/spark/jars
RUN echo "spark.driver.extraJavaOptions=-Dhdp.version=$HDP_VERSION" >> /opt/spark/conf/spark-defaults.conf

COPY conf/slaves /opt/hadoop/etc/hadoop

RUN rm -rf /tmp/*
