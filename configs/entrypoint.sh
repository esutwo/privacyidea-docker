#!/bin/sh

# Check for DB Up
if [ "$DB_CHECK" = 'True' ]; then

    # these are pretty awful and could use some optimization
    host = $(echo $DATABASE_URI | awk -F '@' '{print $2}' | awk -F '/' '{print $1}' | awk -F ':' '{print $1}')
    port = $(echo $DATABASE_URI | awk -F '@' '{print $2}' | awk -F '/' '{print $1}' | awk -F ':' '{print ($2=="" ? "3306" : $2)}')

    status=$(nc -z $host $port; echo $?)
    while [ $status != 0 ]
    do
        sleep 1s
        status=$(nc -z $host $port; echo $?)
    done
fi

if [ ! -f "$PI_ENCFILE" ]; then
    /opt/privacyidea/bin/pi-manage create_enckey
fi
if [ ! -f "$PI_AUDIT_KEY_PRIVATE" ]; then
    /opt/privacyidea/bin/pi-manage create_audit_keys
fi

# Check if DB is initialized
if ! /opt/privacyidea/bin/pi-manage event list &> /dev/null; then
    /opt/privacyidea/bin/pi-manage createdb
    /opt/privacyidea/bin/pi-manage db stamp head -d /opt/privacyidea/lib/privacyidea/migrations/
fi

if [ "$DEBUG" = 'True' ]; then
    echo "DEBUG mode enabled"
    pi-manage runserver
else
    /opt/privacyidea/bin/gunicorn 'privacyidea.app:create_app(config_name="production")' -b 0.0.0.0:8000
fi