FROM python:3.7-slim-bullseye

ARG PI_VERSION=3.6
ARG GUNICORN_VERSION=20.1.0

RUN \
    # Install netcat & curl
    apt-get update && apt-get install curl netcat -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Setup ENV & Install Gunicorn
    mkdir -p /pi/mnt/log /pi/mnt/certs && \
    pip install --upgrade pip && \
    pip install virtualenv && \
    virtualenv /opt/privacyidea && \
    cd /opt/privacyidea && \
    . bin/activate && \
    pip install gunicorn==${GUNICORN_VERSION} && \
    # Install PrivacyIdea
    pip install -r https://raw.githubusercontent.com/privacyidea/privacyidea/v${PI_VERSION}/requirements.txt && \
    pip install privacyidea==${PI_VERSION}

# Update Path
ENV PATH="/opt/privacyidea/bin:$PATH" 

# Defaults for ENV
ENV PRIVACYIDEA_CONFIGFILE="/pi/pi.cfg"
ENV PI_ENCFILE='/pi/mnt/enckey'
ENV PI_AUDIT_KEY_PRIVATE='/pi/mnt/audit-private.pem'
ENV PI_AUDIT_KEY_PUBLIC='/pi/mnt/audit-public.pem'
ENV PI_LOGCONFIG='/pi/logging.yml'
ENV PI_SCRIPT_SMSPROVIDER_DIRECTORY='/pi/scripts'
ENV GUNICORN_WORKERS=1
ENV GUNICORN_THREADS=1

ADD ./configs/ /pi/
ADD ./scripts/ /pi/scripts/

ENTRYPOINT [ "/pi/entrypoint.sh" ]
