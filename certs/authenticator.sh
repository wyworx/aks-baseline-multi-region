#!/bin/bash

STORAGE_ACCOUNT_NAME=$1

echo $CERTBOT_VALIDATION>${CERTBOT_TOKEN}.txt


echo "Uploading validation token to $STORAGE_ACCOUNT_NAME"

#az storage blob upload --account-name $STORAGE_ACCOUNT_NAME -c \$web -n "${CERTBOT_TOKEN}" -f "./${CERTBOT_TOKEN}.txt" --auth-mode key --only-show-errors

./azcopy copy "./${CERTBOT_TOKEN}.txt" "https://regionhq6kwyzw2one4.blob.core.windows.net/\$web/${CERTBOT_TOKEN}?sv=2020-08-04&ss=bfqt&srt=sco&sp=rwdlacupitfx&se=2021-12-03T22:14:31Z&st=2021-11-22T14:14:31Z&sip=100.34.230.121&spr=https&sig=DoTb54mpM1wGeo9Zkg%2FAdD0hxlgS38VHBtOIz0vR1gU%3D"
#./azcopy copy "./${CERTBOT_TOKEN}.txt" "https://regionhq6kwyzw2one4.blob.core.windows.net/\$web/.well-known/acme-challenge/${CERTBOT_TOKEN}?sv=2020-08-04&ss=bfqt&srt=sco&sp=rwdlacupitfx&se=2021-12-03T22:14:31Z&st=2021-11-22T14:14:31Z&sip=100.34.230.121&spr=https&sig=DoTb54mpM1wGeo9Zkg%2FAdD0hxlgS38VHBtOIz0vR1gU%3D"

#./azcopy copy $source $blob

sleep 10

#rm ${CERTBOT_TOKEN}.txt