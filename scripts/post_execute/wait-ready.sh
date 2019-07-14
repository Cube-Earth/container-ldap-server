#!/bin/sh
n=15
sleep 0.5
ldapsearch -LLL -b  cn=config objectClass=olcMdbConfig olcSuffix >/dev/null && rc=0 || rc=$?
while [[ "$rc" -ne 0 ]] && [[ "$n" -gt 0 ]]
do
	n=$((n-1))
	if [[ "$n" -le 0 ]]
	then
		echo "ERROR: ldap server did not start in a reasonable amount of time!"
		exit 1
	fi
	sleep 0.5
	ldapsearch -LLL -b cn=config objectClass=olcMdbConfig olcSuffix >/dev/null && rc=0 || rc=$?
done