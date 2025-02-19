#!/bin/bash

set -e

# Set Staging server if parameter is set
USE_STAGING_SERVER="${USE_STAGING_SERVER+--server=https://acme-staging-v02.api.letsencrypt.org/directory}"

# On Startup
# Lets Encrypt Initialize
./lego $USE_STAGING_SERVER --dns-timeout 30 -k rsa2048 -m $LETSENCRYPT_EMAIL -dns gcloud $DOMAINS_LIST -a run

# Create certificate chain
CERT=$(ls -1 /root/.lego/certificates | grep crt\$ | grep -m1 -v issuer)
CERT_ISSUER=$(ls -1 /root/.lego/certificates | grep crt\$ | grep -m1 issuer)
KEY=$(ls -1 /root/.lego/certificates | grep key\$)
cat /root/.lego/certificates/$CERT /root/.lego/certificates/$CERT_ISSUER > cert.crt

# Create name for new certificate in gcloud
CERT_ID=${CERT_ID_PREFIX:-cert}-$(cat /dev/urandom | tr -dc 'a-z' | fold -w 16 | head -n 1)
OLD_CERT_ID=$(gcloud -q compute target-https-proxies list --filter "name=${TARGET_PROXY}" | sed -n 2p | awk '{print $2}')

# Generate new gcloud certificate and attach to https proxy
[[ -v GCE_REGION ]] && REGION_ARGS="--region=$GCE_REGION"
gcloud -q compute ssl-certificates create $CERT_ID --certificate=cert.crt --private-key=/root/.lego/certificates/$KEY $REGION_ARGS
gcloud -q compute target-https-proxies update $TARGET_PROXY --ssl-certificates $CERT_ID $REGION_ARGS
rm cert.crt

# Remove old, unused certificate
gcloud -q compute ssl-certificates delete $OLD_CERT_ID $REGION_ARGS
