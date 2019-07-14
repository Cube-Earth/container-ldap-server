#!/bin/lsh

basedir=`dirname "$0"`

while getopts ":i" opt; do
    case "${opt}" in
        i)
            whileInitializing=$OPTARG
            ;;
		\?)
      		echo "Invalid option: -$OPTARG" >&2
      		;;
          esac
done
shift $((OPTIND-1))

[[ "${whileInitializing-true}" == "true" ]] && [[ "${INITIALIZE-}" != "true" ]] && echo "nothing to do!" && exit 0

OFS=$IFS
IFS=$'\n'

for file in $(find /ldif -type f -maxdepth 1 -name "*.modify.ldif" || rc=$?)
do
	echo
	echo "--- modify ldif $file ----------------"
	ldapmodify -f <(awk -f "/usr/local/bin/awk/ldif-pwds.awk" < "$file") && rc=0 || rc=$?
	echo
	[[ $rc != 0 ]] && echo "ERROR: script failed with exit code $rc!" || echo "SUCCESS: script succeeded!"
	echo "--- end script $file ------------------"
	echo
done


for var in $(set | awk "{ l=1 } !c && match(\$0, /^[^=]+=/) { print substr(\$0,0,RLENGTH-1); \$0=substr(\$0,RLENGTH+1); c=!match(\$0, /^((\”'\")|('[^']*'))*\$/); l=0 } l && c { c=!match(\$0, /^[^']*'((\”'\")|('[^']*'))*$/) }" | grep -E '^LDAP_MODIFY|LDAP_MODIFY_.*$' | sort || rc=$?)
do
	echo
	echo "--- modify ldif $var ----------------"
	eval SCRIPT=\$$var
	ldapmodify -f <(awk -f "/usr/local/bin/awk/ldif-pwds.awk" <<< "$SCRIPT") && rc=0 || rc=$?
	echo
	[[ $rc != 0 ]] && echo "ERROR: script failed with exit code $rc!" || echo "SUCCESS: script succeeded!"
	echo "--- end script $var ------------------"
	echo
done

for file in $(find /ldif -type f -maxdepth 1 -name "*.add.ldif" || rc=$?)
do
	echo
	echo "--- add ldif $file ----------------"
	ldapadd -f <(awk -f "/usr/local/bin/awk/ldif-pwds.awk" < "$file") && rc=0 || rc=$?
	echo
	[[ $rc != 0 ]] && echo "ERROR: script failed with exit code $rc!" || echo "SUCCESS: script succeeded!"
	echo "--- end script $file ------------------"
	echo
done

for var in $(set | awk "{ l=1 } !c && match(\$0, /^[^=]+=/) { print substr(\$0,0,RLENGTH-1); \$0=substr(\$0,RLENGTH+1); c=!match(\$0, /^((\”'\")|('[^']*'))*\$/); l=0 } l && c { c=!match(\$0, /^[^']*'((\”'\")|('[^']*'))*$/) }" | grep -E '^LDAP_ADD|LDAP_ADD_.*$' | sort || rc=$?)
do
	echo
	echo "--- add ldif $var ----------------"
	eval SCRIPT=\$$var
	ldapadd -f <(awk -f "/usr/local/bin/awk/ldif-pwds.awk" <<< "$SCRIPT") && rc=0 || rc=$?
	echo
	[[ $rc != 0 ]] && echo "ERROR: script failed with exit code $rc!" || echo "SUCCESS: script succeeded!"
	echo "--- end script $var ------------------"
	echo
done

IFS=$OFS
