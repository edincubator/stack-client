from string import Template

template = Template(open('/tmp/krb5.conf.tmpl', 'r').read())

krb_config = template.substitute(
    KERBEROS_REALM=open('/run/secrets/KERBEROS_REALM', 'r').read(),
    KADM_SERVER=open('/run/secrets/KADM_SERVER', 'r').read(),
    KDC_SERVER=open('/run/secrets/KDC_SERVER', 'r').read()
)

f = open('/etc/krb5.conf', 'w')
f.write(krb_config)
f.close()
