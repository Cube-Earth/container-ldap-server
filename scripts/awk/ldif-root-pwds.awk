function process() {
	if(root) {
		print "olcRootPW:" rootPwd
	}
}

/^ *olcRootDN *:/ { root=1 }
/^ *olcRootPW *:/ { skip=1 }
/^ *$/ { process(); root=0 }
{ if(!skip) { print } else { skip=0 } }
END { process() }