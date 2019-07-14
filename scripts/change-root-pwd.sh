#!/bin/lsh

def_pwd=$(curl -Ls https://pod-cert-server/pwd/root)
pwd=$(slappasswd -s ${1-$def_pwd})

ldapmodify << E0F
dn: olcDatabase={0}config,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $pwd
E0F

ldapmodify << E0F
dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $pwd
E0F
