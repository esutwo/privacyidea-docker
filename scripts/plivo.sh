#!/bin/sh

# Expects phone as the parameter and the message from stdin

# Requirements:

if [ -z "$PLIVO_AUTH_ID" ] || [ -z "$PLIVO_AUTH_TOKEN" ] || [ -z "$PLIVO_PHONE_NUMBER" ]; then
    echo "PLIVO_AUTH_ID, PLIVO_AUTH_TOKEN, and PLIVO_PHONE_NUMBER must be defined."
    exit 1
fi

# Capture STDIN
MESSAGE=$(cat -)
PHONE_NUMBER=$1

JSON="{\"src\": \"$PLIVO_PHONE_NUMBER\", \"dst\": \"$PHONE_NUMBER\", \"text\": \"Your verification code is $MESSAGE\"}"

curl -i --user $PLIVO_AUTH_ID:$PLIVO_AUTH_TOKEN \
    -H "Content-Type: application/json" \
    -d "$JSON" \
    https://api.plivo.com/v1/Account/$PLIVO_AUTH_ID/Message/
