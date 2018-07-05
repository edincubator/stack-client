# Edincubator stack-client

This is the docker image for interacting with EDI's Big Data Stack. This image
has clients installed and configured for working with the following tools:

* HDFS
* YARN
* Spark2
* Hive2 (+ Beeline)
* HBase
* Kafka
* Solr
* Oozie
* Pig

For building the image, the following command should be executed:
```
docker build --build-arg AMBARI_USER=ambariuser --build-arg AMBARI_PASSWORD=ambaripassword --build-arg AMBARI_HOST=ambari-host:ambari-port --build-arg CLUSTER_NAME=cluster_name --build-arg KERBEROS_REALM=EXAMPLE.COM --build-arg KADM_SERVER=kadmin.host --build-arg KDC_SERVER=kdc.host --build-arg MASTER_HOST=master.node.host -t edincubator/stack-client .
```
