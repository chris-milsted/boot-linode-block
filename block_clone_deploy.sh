#!/bin/bash

# Modify this to be ID of block volume you want to clone from
SOURCE_BLOCK_ID=13347613
RANDID=$RANDOM

START_TIME=$(date)

# Clone block volume from golden image

NEW_VOLUME=$(curl -s -X POST \
     --url https://api.linode.com/v4/volumes/$SOURCE_BLOCK_ID/clone \
     --header 'accept: application/json' \
     --header "authorization: Bearer $TOKEN" \
     --header 'content-type: application/json' \
     --data "
{
  \"label\": \"test-$RANDID\"
}
"
)
echo $NEW_VOLUME | jq
CLONED_BLOCK_ID=$(echo $NEW_VOLUME | jq ".id")
echo $CLONED_BLOCK_ID

# Create Linode

NEW_LINODE=$(curl -s -H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-X POST -d "{
    \"private_ip\": false,
    \"region\": \"gb-lon\",
    \"type\": \"g6-dedicated-2\",
    \"label\": \"test-block$RANDID\",
    \"firewall_id\": 2320246
}" https://api.linode.com/v4/linode/instances)
echo $NEW_LINODE | jq
LINODE_ID=$(echo $NEW_LINODE | jq ".id")
echo $LINODE_ID

# Create Config Profile

NEW_CONFIG=$(curl -s -X POST \
     --url https://api.linode.com/v4/linode/instances/$LINODE_ID/configs \
     --header 'accept: application/json' \
     --header "authorization: Bearer $TOKEN" \
     --header 'content-type: application/json' \
     -d "
{
  \"devices\": {
    \"sda\": {
      \"volume_id\": $CLONED_BLOCK_ID
    }
  },
  \"helpers\": {
    \"network\": true
  },
  \"interfaces\": [
    {
      \"primary\": true,
      \"purpose\": \"public\"
    }
  ],
  \"kernel\": \"linode/grub2\",
  \"label\": \"Block Boot\"
}
")
echo $NEW_CONFIG | jq
CONFIG_ID=$(echo $NEW_CONFIG | jq ".id")
echo $CONFIG_ID

# Boot

while [ "$BOOT_JSON" != "{}" ]; do
  echo "Trying to boot."
  BOOT_JSON=$(curl -sH "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -X POST -d "{\"config_id\": $CONFIG_ID}" \
      https://api.linode.com/v4/linode/instances/$LINODE_ID/reboot)
  echo $BOOT_JSON | jq
  FINISH_TIME=$(date)
  sleep 1
done
echo "All done!"
echo
echo "Start Time  : $START_TIME"
echo "Finish Time : $FINISH_TIME"

exit 0