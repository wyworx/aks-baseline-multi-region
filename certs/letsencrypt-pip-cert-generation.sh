#!/bin/bash -x

IP_RESOURCE_ID=$1

LOCATION=$(az network public-ip show --ids $IP_RESOURCE_ID --query location -o tsv)
RGNAME="rg-lets-encrypt-cert-validator-${LOCATION}"

FQDN=$(az network public-ip show --ids $IP_RESOURCE_ID --query dnsSettings.fqdn -o tsv)
SUBDOMAIN=$(az network public-ip show --ids $IP_RESOURCE_ID --query dnsSettings.domainNameLabel -o tsv)

echo "Location: $LOCATION"
echo "DNS Prefix: $SUBDOMAIN"
echo "FQDN: $FQDN"
echo "Existing IP Resource ID: $IP_RESOURCE_ID"

echo "Creating temporary Resource Group $RGNAME"
az group create -n $RGNAME -l $LOCATION

echo "Deploying Azure resources used in validation; this may take 20 minutes."
az deployment group create -g $RGNAME -u "https://raw.githubusercontent.com/mspnp/letsencrypt-pip-cert-generation/a4f89d43004d4250af02c2bc2194d62467690422/resources-stamp.json" -p location=${LOCATION} subdomainName=${SUBDOMAIN} ipResourceId=${IP_RESOURCE_ID}

STORAGE_ACCOUNT_NAME=$(az deployment group show -g $RGNAME -n resources-stamp --query properties.outputs.storageAccountName.value -o tsv)

echo "Enabling web hosting on $STORAGE_ACCOUNT_NAME"
az storage blob service-properties update --account-name $STORAGE_ACCOUNT_NAME --static-website true --auth-mode login

echo "Uploading placeholder to storage"
echo pong>ping.txt
#az storage blob upload --account-name $STORAGE_ACCOUNT_NAME -c \$web -n ping -f ./ping.txt --auth-mode key

azcopy copy "./ping.txt" "https://regionwve3oxteiqbru.blob.core.windows.net/\$web/ping?sv=2020-08-04&ss=bfqt&srt=sco&sp=rwdlacupitfx&se=2021-12-05T00:46:41Z&st=2021-11-24T16:46:41Z&spr=https,http&sig=aLCNDn0qgeOosPZ7fzz3lQo5%2BFFHtgTjNpXti44o1Mg%3D"

echo "Starting cert generation and validation"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#certbot certonly --manual --manual-auth-hook "${DIR}/authenticator.sh ${STORAGE_ACCOUNT_NAME}" -d $FQDN --config-dir ./certs/output/etc/letsencrypt --work-dir ./certs/output/var/lib/letsencrypt --logs-dir ./certs/output/var/log/letsencrypt
certbot certonly --manual -d $FQDN --config-dir ./certs/output/etc/letsencrypt --work-dir ./certs/output/var/lib/letsencrypt --logs-dir ./certs/output/var/log/letsencrypt

openssl pkcs12 -export -out ${SUBDOMAIN}.pfx -inkey ./certs/output/etc/letsencrypt/live/${FQDN}/privkey.pem -in ./certs/output/etc/letsencrypt/live/${FQDN}/cert.pem -certfile ./certs/output/etc/letsencrypt/live/${FQDN}/chain.pem -passout pass:

echo "Deleting resources"
az group delete -n $RGNAME --yes --no-wait
rm -rf ./certs/output ./ping.txt