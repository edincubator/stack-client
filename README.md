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
docker build --secret id=KERBEROS_REALM,src=secrets/KERBEROS_REALM --secret id=KADM_SERVER,src=secrets/KADM_SERVER --secret id=KDC_SERVER,src=secrets/KDC_SERVER --secret id=AMBARI_USER,src=secrets/AMBARI_USER --secret id=AMBARI_PASSWORD,src=secrets/AMBARI_PASSWORD --secret id=AMBARI_HOST,src=secrets/AMBARI_HOST --secret id=CLUSTER_NAME,src=secrets/CLUSTER_NAME --secret id=MASTER_HOST,src=secrets/MASTER_HOST -t edincubator/stack-client .
```
