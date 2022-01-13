FROM python:3.7-slim-bullseye

ARG PI_VERSION=3.6

ENV PRIVACYIDEA_CONFIGFILE="/pi/pi.cfg"

# Defaults for ENV
ENV PI_ENCFILE='/pi/mnt/enckey'
ENV PI_AUDIT_KEY_PRIVATE='/pi/mnt/audit-private.pem'
ENV PI_AUDIT_KEY_PUBLIC='/pi/mnt/audit-public.pem'
ENV PI_LOGCONFIG='/pi/logging.yml'

RUN \
    # Install netcat
    apt-get update && apt-get install netcat -y && apt-get clean && \
    # Setup ENV & Install Gunicorn
    mkdir -p /pi/mnt/log /pi/mnt/certs && \
    pip install --upgrade pip && \
    pip install virtualenv && \
    virtualenv /opt/privacyidea && \
    cd /opt/privacyidea && \
    . bin/activate && \
    pip install gunicorn && \
    # Install PrivacyIdea
    pip install -r https://raw.githubusercontent.com/privacyidea/privacyidea/v${PI_VERSION}/requirements.txt && \
    pip install privacyidea==${PI_VERSION}

ADD ./configs/ /pi/

ENTRYPOINT [ "/pi/entrypoint.sh" ]