FROM centos:7

RUN yum update -y && yum install -y krb5-workstation wget which

COPY conf/krb5.conf /etc/krb5.conf

WORKDIR /tmp

# Download components
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
RUN wget wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.rpm"

# Install components
RUN tar -xf /tmp/hadoop-2.7.3.tar.gz
RUN mv /tmp/hadoop-2.7.3 /opt/hadoop-2.7.3
RUN ln -s /opt/hadoop-2.7.3/ /opt/hadoop

RUN yum localinstall -y jdk-8u161-linux-x64.rpm

# Set environment variables
ENV PATH $PATH:/opt/hadoop/bin
ENV JAVA_HOME /usr/java/latest

# Download configurations
# WARNING: REPLACE BY REAL HOST
RUN curl --user ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X GET http://${AMBARI_HOST}/api/v1/clusters/EDI_test/services/HDFS/components/HDFS_CLIENT?format=client_config_tar -o hdfs-config.tar.gz
RUN tar -xf hdfs-config.tar.gz
RUN cp core-site.xml /opt/hadoop/etc/hadoop
RUN cp hdfs-site.xml /opt/hadoop/etc/hadoop
