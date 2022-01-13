# PrivacyIdea Docker Image

The image packages PrivacyIdea since there is no official image to handle the packaging.

## Usage

The majority of the configuration is done via environment variables and config files stored within the container at `/pi`. A sub-directory within that folder can be mounted to store the files necessary for persistance.

```bash
docker build -t privacyidea:latest .
docker run --rm -it -v $(pwd)/data:/pi/mnt \
           -e SECRET_KEY='bigsecret' \
           -e PI_PEPPER='dontusethis' \
           -p 8000:8000 \
           privacyidea:latest
```

### Create an admin user

```bash
docker exec -it privacyidea /opt/privacyidea/bin/pi-manage admin bob -p bobspwd
```

## Environment Vars

| Var                      | Default                         | Description |
| ------------------------ | ------------------------------- | ----------- |
| `DEBUG`                  | `False`                         | Enables debug logs & test server |
| `SECRET_KEY`             | random                          | Used to encrypt values. Should be unique |
| `PI_PEPPER`              | random                          | Used to encrypt admin passwords. Should be unique |
| `DATABASE_URI`           | `sqlite:////pi/mnt/data.sqlite` | Used to connect to db. See [here](https://privacyidea.readthedocs.io/en/latest/faq/mysqldb.html#mysqldb) for more |
| `DB_CHECK`               | <NONE>                          | Starts a while loop waiting for the database to come online when set to `True` |
| `PI_LOGCONFIG`           | `/pi/logging.yml`               | [Log config location](https://privacyidea.readthedocs.io/en/latest/installation/system/logging.html#debug-log) |
| `PI_ENCFILE`             | `/pi/mnt/enckey`                | This is used to encrypt the token data and token passwords. File will be generated at specified location if one does not exist |
| `PI_AUDIT_KEY_PRIVATE`   | `/pi/mnt/audit-private.pem`     | This is used to sign the audit log. File will be generated at specified location if one does not exist |
| `PII_AUDIT_KEY_PUBLIC`   | `/pi/mnt/audit-public.pem`      | This is used to sign the audit log. File will be generated at specified location if one does not exist |
| `PRIVACYIDEA_CONFIGFILE` | `/pi/pi.cfg`                    | [Config file](https://privacyidea.readthedocs.io/en/latest/installation/system/inifile.html#cfgfile) location |