# Dolibarr CRM

https://github.com/Dolibarr/dolibarr

Runs Dolibarr CRM with the following stack, all Alpine:

- NGINX
- PHP-FPM + OPcache
- memcached
- PostgreSQL

Ready to be run behind Traefik out of the box.

This work is based on https://github.com/Monogramm/docker-dolibarr, make sure to check them out. Their solution is more flexible but requires a bit more work to deploy.

## Config

See all possible values in [env.default](env.default) and [entrypoint.sh](entrypoint.sh).

For a dev env, all default should be fine. 

Otherwise your `.env` should probably look like this:

```bash
## Dolibarr
DOLIBARR_DATA=/secure/folder/with/backups/
DOLIBARR_DOMAIN=www.mydolibarr.com
DOLI_URL_ROOT=https://www.mydolibarr.com
DOLI_PROD=1

## PHP-FPM
PHP_DISPLAY_ERRORS=Off
PHP_INI_DATE_TIMEZONE=Europe/Paris

## PostgreSQL
POSTGRES_DB=dolibarr_prod
POSTGRES_USER=dolibarr_admin
POSTGRES_PASSWORD=securepassword
```

## Install

Make sure to setup your .env before installing.

```bash
docker network create web
docker-compose up -d

# with Traefik
x-www-browser https://www.mydolibarr.com/install/

# without Traefik
x-www-browser $(docker inspect --format="{{.NetworkSettings.Networks.web.IPAddress}}" dolibarr_web)/install/
```

## Uninstall

```bash
docker-compose down
rm -rf ./data/
```
