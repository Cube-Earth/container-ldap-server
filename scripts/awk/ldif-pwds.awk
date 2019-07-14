function trim(s) {
	sub(/^[ \t\r\n]+/, "", s);
	sub(/[ \t\r\n]+$/, "", s);
	return s;
}

function process() {
	if(!dn || !person) {
		return
	}
	if(match(dn, "uid *= *[^,]+")) {
		u=substr(dn,RSTART,RLENGTH);
		u=trim(substr(u, index(u, "=")+1))
		system("echo -n 'userpassword: '; slappasswd -s `curl -Ls https://pod-cert-server/pwd/" u "`")
	}
}

/^ *dn *:/ { dn=trim(substr($0, index($0, ":")+1)) }
/^ *objectclass *: *person *$/ { person=1 }
/^ *userpassword *:/ { skip=1 }
/^ *$/ { process(); dn=""; person=0 }
{ if(!skip) { print } else { skip=0 } }
END { process() }