#!/bin/sh

# Check for DB Up
if [ "$DB_CHECK" = 'True' ]; then

    # these are pretty awful and could use some optimization
    host=$(echo $DATABASE_URI | awk -F '@' '{print $2}' | awk -F '/' '{print $1}' | awk -F ':' '{print $1}')
    port=$(echo $DATABASE_URI | awk -F '@' '{print $2}' | awk -F '/' '{print $1}' | awk -F ':' '{print ($2=="" ? "3306" : $2)}')
    status=$(nc -z $host $port; echo $?)
    while [ $status != 0 ]
    do
        sleep 1s
        status=$(nc -z $host $port; echo $?)
    done
fi

# Check if DB is initialized
if ! /opt/privacyidea/bin/pi-manage event list > /dev/null 2>&1; then
    echo "Creating DB tables"
    /opt/privacyidea/bin/pi-manage createdb
    echo "Performing DB Stamp"
    /opt/privacyidea/bin/pi-manage db stamp head -d /opt/privacyidea/lib/privacyidea/migrations/
fi

if [ ! -f "$PI_ENCFILE" ]; then
    echo "Creating encfile at $PI_ENCFILE"
    /opt/privacyidea/bin/pi-manage create_enckey
fi
if [ ! -f "$PI_AUDIT_KEY_PRIVATE" ]; then
    echo "Creating certs at $PI_AUDIT_KEY_PRIVATE and $PI_AUDIT_KEY_PUBLIC"
    /opt/privacyidea/bin/pi-manage create_audit_keys
fi

if [ "$HIDE_WELCOME" = 'True' ]; then
    echo "Hiding ALL welcome dialogs. Only perform this in a development environment." 
    sed -i "s/\$('#dialogWelcome')\.modal(\"show\")/\$('#dialogWelcome')\.modal(\"hide\")/g" /opt/privacyidea/lib/python3.7/site-packages/privacyidea/static/components/login/controllers/loginControllers.js
fi

if [ "$DEBUG" = 'True' ]; then
    echo "DEBUG mode enabled"
    pi-manage runserver
else
    /opt/privacyidea/bin/gunicorn --workers=$GUNICORN_WORKERS --threads=$GUNICORN_THREADS 'privacyidea.app:create_app(config_name="production")' -b 0.0.0.0:8000
fi
