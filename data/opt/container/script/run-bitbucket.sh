#!/bin/bash

. /opt/container/script/unit-utils.sh

# Check required environment variables and fix the NGINX unit configuration.

checkCommonRequiredVariables

notifyUnitLaunched

unitConf=`copyUnitConf nginx-unit-bitbucket`

logUrlPrefix "bitbucket"

# Fix Bitbucket configuration.

bitbucket_config=/opt/bitbucket/conf/server.xml

cp /opt/container/template/server.xml.template ${bitbucket_config}

fileSubstitute ${bitbucket_config} NGINX_UNIT_HOSTS ${NGINX_UNIT_HOSTS}
fileSubstitute ${bitbucket_config} NGINX_URL_PREFIX `normalizeSlashesSingleSlashToEmpty ${NGINX_URL_PREFIX}`

notifyUnitStarted

# Import certificate (so we can integrate with other Atlassian product instances).

printf "changeit\nyes" | keytool -import -trustcacerts -alias root \
     -file /opt/container/shared/etc/letsencrypt/live/${NGINX_UNIT_HOSTS}/fullchain.pem -keystore \
     /usr/lib/jvm/default-jvm/jre/lib/security/cacerts

# Fix umask settings per Bitbucket recommendations.

umask 0027

# Start Bitbucket.

startProcessWithTrap onProcessStopped ${unitConf} /opt/bitbucket/bin/start-webapp.sh -fg
