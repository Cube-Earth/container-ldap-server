#!/bin/lsh

i=$(find /ldif -type f -maxdepth 1 \( -name "*.ldif" -and ! -name "*.init.ldif" \) | wc -l)
j=$(set | awk "{ l=1 } !c && match(\$0, /^[^=]+=/) { print substr(\$0,0,RLENGTH-1); \$0=substr(\$0,RLENGTH+1); c=!match(\$0, /^((\”'\")|('[^']*'))*\$/); l=0 } l && c { c=!match(\$0, /^[^']*'((\”'\")|('[^']*'))*$/) }" | grep -E '^LDAP_ADD|LDAP_ADD_.*$' || rc=$? | wc -l)
k=$(set | awk "{ l=1 } !c && match(\$0, /^[^=]+=/) { print substr(\$0,0,RLENGTH-1); \$0=substr(\$0,RLENGTH+1); c=!match(\$0, /^((\”'\")|('[^']*'))*\$/); l=0 } l && c { c=!match(\$0, /^[^']*'((\”'\")|('[^']*'))*$/) }" | grep -E '^LDAP_MODIFY|LDAP_MODIFY_.*$' || rc=$? | wc -l)

echo $((i+j+k))
