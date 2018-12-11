from string import Template

template = Template(open('/tmp/kafka_jaas.conf.tmpl', 'r').read())

kafka_config = template.substitute(
    KERBEROS_REALM=open('/run/secrets/KERBEROS_REALM', 'r').read(),
    MASTER_HOST=open('/run/secrets/MASTER_HOST', 'r').read()
)

f = open('/usr/hdp/current/kafka-broker/config/kafka_jaas.conf', 'w')
f.write(kafka_config)
f.close()
