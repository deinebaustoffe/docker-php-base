<p align="center">
    <img src="https://github.com/deinebaustoffe/docker-php-base/raw/master/.github/repository_logo.png">
</p>

# php-base
Docker Base Image with PHP 7.4

# Laravel Application - Quick Run
Using the Laravel installer you can get up and running with a Laravel application inside Docker in minutes.

- Create a new Laravel application `$ laravel new testapp`
- Change to the applications directory `$ cd testapp`
- Start the container and attach the application. `$ docker run -d -p 4488:80 --name=testapp -v $PWD:/var/www registry.db-ops.de/dockerfiles/php-base:latest`
- Visit the Docker container URL like [http://0.0.0.0:4488](http://0.0.0.0:4488). Profit!

### Args
Here are some args

- `NGINX_HTTP_PORT` - HTTP port. Default: `80`.
- `NGINX_HTTPS_PORT` - HTTPS port. Default: `443`.
- `PHP_VERSION` - The PHP version to install. Supports: `7.3`, `7.4`. Default: `7.4`.
- `ALPINE_VERSION` - The Alpine version. Supports: `3.9`. Default: `3.9`.

### Environment Variables
Here are some configurable environment values.

- `WEBROOT` – Path to the web root. Default: `/var/www`
- `WEBROOT_PUBLIC` – Path to the web root. Default: `/var/www/public`
- `COMPOSER_DIRECTORY` - Path to the `composer.json` containing directory. Default: `/var/www`.
- `COMPOSER_UPDATE_ON_BUILD` - Should `composer update` run on build. Default: `0`.
- `LARAVEL_APP` - Is this a Laravel application. Default `0`.
- `RUN_LARAVEL_SCHEDULER` - Should the Laravel scheduler command run. Only works if `LARAVEL_APP` is `1`. Default: `0`.
- `RUN_LARAVEL_MIGRATIONS_ON_BUILD` - Should the migrate command run during build. Only works if `LARAVEL_APP` is `1`. Default: `0`.
- `PRODUCTION` – Is this a production environment. Default: `0`
- `PHP_MEMORY_LIMIT` - PHP memory limit. Default: `128M`
- `PHP_POST_MAX_SIZE` - Maximum POST size. Default: `50M`
- `PHP_UPLOAD_MAX_FILESIZE` - Maximum file upload file. Default: `10M`.
- `AUTH_JSON` - Determins if and `auth.json` is present. Default: `0`.
- `AUTH_JSON_PATH` - If `AUTH_JSON` is set to `1` the image will copy the file to the composer-root.

### Running a Laravel Application in a container
Use the following code as `Dockerfile` template:
```
FROM registry.db-ops.de/dockerfiles/php-base:latest

LABEL maintainer="Florian Wartner <florian.wartner@deinebaustoffe.de>"

ENV LARAVEL_APP=1
ENV PRODUCTION=1
ENV RUN_LARAVEL_SCHEDULER=1
ENV AUTH_JSON=0
ENV AUTH_JSON_PATH=auth.json
ENV RUN_LARAVEL_MIGRATIONS_ON_BUILD=0

COPY . /var/www/

ADD horizon.conf /etc/supervisor/horizon.conf

WORKDIR /var/www
RUN rm -rf vendor/ \
    && rm -rf node_modules/ \
    && cp .env.docker .env \
    && composer install --no-dev \
    && chmod -Rf 777 /var/www/storage/
```