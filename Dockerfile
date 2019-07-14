FROM alpine:latest

ENV LDAPI_URI="ldapi://%2Frun%2Fopenldap%2Fldapi/"

RUN apk --no-cache add openldap openldap-clients openldap-backend-all openldap-overlay-all openssl sudo bash && \
	adduser -D -g '' -s /sbin/nologin user && \
	mkdir /run/openldap /etc/openldap/slapd.d && \
	chown ldap:ldap /run/openldap /etc/openldap/slapd.d /var/lib/openldap/openldap-data && \
	echo -e "URI $LDAPI_URI\nSASL_MECH EXTERNAL" > ~/.ldaprc && \
	sh -c "$(wget -qO- https://github.com/Cube-Earth/Scripts/raw/master/shell/k8s/pod/prepare.sh)" - -c certs -c run && \
	mkdir /ldif

EXPOSE 389 636

COPY scripts/ /usr/local/bin/

RUN chmod -R +x /usr/local/bin/*.sh

COPY ldif/ /ldif/

VOLUME [ "/etc/openldap/slapd.d", "/var/lib/openldap/openldap-data", "/ldif" ]

ENTRYPOINT [ "/usr/local/bin/run.sh" ]

