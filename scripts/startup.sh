#!/bin/bash

set -o errexit
set -o nounset

[[ -f /var/lib/openldap/openldap-data/data.mdb ]] && initialize="false" || initialize="true"

if [[ "${RECONFIGURE:-}" = "true" ]]
then
	rm -Rf /etc/openldap/slapd.d/*
#	rm -Rf /var/lib/openldap/openldap-data/*
	initialize=true
fi

if [[ "$initialize" = "true" ]]
then
	if [[ -z "${SLAPD_PASSWORD-}" ]]
	then
		SLAPD_PASSWORD=$(slappasswd -s $(curl -Ls https://pod-cert-server/pwd/ldap-root))
	fi
	
	if [[ -f /ldif/slapd.init.ldif ]]
	then
		file="/ldif/slapd.init.ldif"
	else
		file="/usr/local/bin/ldif/slapd.ldif"
	fi

	/usr/sbin/slapadd -v -n 0 -F /etc/openldap/slapd.d -d 2 -l <(cat "$file" | awk -v rootPwd="$SLAPD_PASSWORD" -f /usr/local/bin/awk/ldif-root-pwds.awk)
	chown -R ldap:ldap /etc/openldap/slapd.d/
else
	if [[ ! -z "${SLAPD_PASSWORD-}" ]]
	then
		PWD_ENC=$(echo "$SLAPD_PASSWORD" | base64)
		find /etc/openldap/slapd.d/ -type f | xargs -n1 grep -l -e olcRootPW | xargs -n1 sed -i'' "s/\\( *olcRootPW *:\\).*\$/\\1: $PWD_ENC/g"
	fi
fi

export INITIALIZE=${initialize-false}
[[ "$INITIALIZE" = "true" ]] && touch /run/initialize.state

slapd -h "ldap:/// ldaps:/// $LDAPI_URI" -d ${DEBUG_LEVEL-0} -u ldap -g ldap -F /etc/openldap/slapd.d

