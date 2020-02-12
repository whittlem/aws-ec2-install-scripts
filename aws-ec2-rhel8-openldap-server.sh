#!/usr/bin/bash

yum update -y
yum install openldap openldap-clients -y
yum install openldap-servers --enablerepo=codeready-builder-for-rhel-8-rhui-rpms -y

SERVER_NAME=ldaps-rat
SERVER_IP=$(ifconfig eth0 | grep broadcast | awk {'print $2'})
SERVER_DOMAIN=internal.sytelreply.com
LDAPADM_PASSWD=AmStLnJZOG94TlwqCLho
SLAPD_PASSWD=$(slappasswd -h {SSHA} -s ${LDAPADM_PASSWD})
SLAPD_ROOTNAME="sytelreply"
SLAPD_OLCSUFFIX="dc=internal,dc=$SLAPD_ROOTNAME,dc=com"
SLAPD_OLCROOTDN="cn=ldapadm,$SLAPD_OLCSUFFIX"

echo "$SERVER_IP   $SERVER_NAME.$SERVER_DOMAIN $SERVER_NAME" >> /etc/hosts

systemctl start slapd
systemctl enable slapd

netstat -antup | grep -i 389

mkdir ~/ldapldif
chmod 700 ~/ldapldif

echo "dn: olcDatabase={2}mdb,cn=config" > ~/ldapldif/db.ldif
echo "changetype: modify" >> ~/ldapldif/db.ldif
echo "replace: olcSuffix" >> ~/ldapldif/db.ldif
echo "olcSuffix: $SLAPD_OLCSUFFIX" >> ~/ldapldif/db.ldif
echo "" >> ~/ldapldif/db.ldif
echo "dn: olcDatabase={2}mdb,cn=config" >> ~/ldapldif/db.ldif
echo "changetype: modify" >> ~/ldapldif/db.ldif
echo "replace: olcRootDN" >> ~/ldapldif/db.ldif
echo "olcRootDN: $SLAPD_OLCROOTDN" >> ~/ldapldif/db.ldif
echo "" >> ~/ldapldif/db.ldif
echo "dn: olcDatabase={2}mdb,cn=config" >> ~/ldapldif/db.ldif
echo "changetype: modify" >> ~/ldapldif/db.ldif
echo "replace: olcRootPW" >> ~/ldapldif/db.ldif
echo "olcRootPW: $SLAPD_PASSWD" >> ~/ldapldif/db.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f db.ldif

echo "dn: olcDatabase={1}monitor,cn=config" > ~/ldapldif/monitor.ldif
echo "changetype: modify" >> ~/ldapldif/monitor.ldif
echo "replace: olcAccess" >> ~/ldapldif/monitor.ldif
echo "olcAccess: {0}to * by dn.base=\"gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth\" read by dn.base=\"$SLAPD_OLCROOTDN\" read by * none" >> ~/ldapldif/monitor.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f monitor.ldif

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap:ldap /var/lib/ldap/*

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

echo "dn: $SLAPD_OLCSUFFIX" > ~/ldapldif/base.ldif
echo "dc: $SLAPD_ROOTNAME" >> ~/ldapldif/base.ldif
echo "objectClass: top" >> ~/ldapldif/base.ldif
echo "objectClass: domain" >> ~/ldapldif/base.ldif
echo "" >> ~/ldapldif/base.ldif
echo "dn: $SLAPD_OLCROOTDN" >> ~/ldapldif/base.ldif
echo "objectClass: organizationalRole" >> ~/ldapldif/base.ldif
echo "cn: ldapadm" >> ~/ldapldif/base.ldif
echo "description: LDAP Administrator" >> ~/ldapldif/base.ldif
echo "" >> ~/ldapldif/base.ldif
echo "dn: ou=Users,$SLAPD_OLCSUFFIX" >> ~/ldapldif/base.ldif
echo "objectClass: organizationalUnit" >> ~/ldapldif/base.ldif
echo "ou: Users" >> ~/ldapldif/base.ldif
echo "" >> ~/ldapldif/base.ldif
echo "dn: ou=ServiceAccounts,$SLAPD_OLCSUFFIX" >> ~/ldapldif/base.ldif
echo "objectClass: organizationalUnit" >> ~/ldapldif/base.ldif
echo "ou: ServiceAccounts" >> ~/ldapldif/base.ldif

ldapadd -x -D "$SLAPD_OLCROOTDN" -w ${LDAPADM_PASSWD} -f base.ldif

echo "dn: uid=doej,ou=Users,$SLAPD_OLCSUFFIX" > ~/ldapldif/doej.ldif
echo "objectClass: top" >> ~/ldapldif/doej.ldif
echo "objectClass: account" >> ~/ldapldif/doej.ldif
echo "objectClass: posixAccount" >> ~/ldapldif/doej.ldif
echo "objectClass: shadowAccount" >> ~/ldapldif/doej.ldif
echo "cn: doej" >> ~/ldapldif/doej.ldif
echo "uid: doej" >> ~/ldapldif/doej.ldif
echo "uidNumber: 9999" >> ~/ldapldif/doej.ldif
echo "gidNumber: 100" >> ~/ldapldif/doej.ldif
echo "homeDirectory: /home/doej" >> ~/ldapldif/doej.ldif
echo "loginShell: /bin/bash" >> ~/ldapldif/doej.ldif
echo "gecos: John Doe" >> ~/ldapldif/doej.ldif
echo "userPassword: {crypt}jjoe" >> ~/ldapldif/doej.ldif
echo "shadowLastChange: 17058" >> ~/ldapldif/doej.ldif
echo "shadowMin: 0" >> ~/ldapldif/doej.ldif
echo "shadowMax: 99999" >> ~/ldapldif/doej.ldif
echo "shadowWarning: 7" >> ~/ldapldif/doej.ldif

ldapadd -x -D "$SLAPD_OLCROOTDN" -w ${LDAPADM_PASSWD} -f doej.ldif

${LDAPADM_PASSWD} -s jjoe -D "$SLAPD_OLCROOTDN" -w ${LDAPADM_PASSWD} -x "uid=doej,ou=Users,$SLAPD_OLCSUFFIX"

ldapsearch -x -cn=doej -b $SLAPD_OLCSUFFIX

#ldapdelete -x -D "$SLAPD_OLCROOTDN" -w ${LDAPADM_PASSWD} "uid=doej,ou=Users,$SLAPD_OLCSUFFIX"

echo "local4.* /var/log/ldap.log" >> /etc/rsyslog.conf 
service rsyslog restart
