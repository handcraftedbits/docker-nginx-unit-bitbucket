# NGINX Host Bitbucket Unit [![Docker Pulls](https://img.shields.io/docker/pulls/handcraftedbits/nginx-unit-bitbucket.svg?maxAge=2592000)](https://hub.docker.com/r/handcraftedbits/nginx-unit-bitbucket)

A [Docker](https://www.docker.com) container that provides an
[Atlassian Bitbucket](https://www.atlassian.com/software/bitbucket) unit for
[NGINX Host](https://github.com/handcraftedbits/docker-nginx-host).

# Features

* Atlassian Bitbucket 4.12.1
* NGINX Host SSL certificates are automatically imported into Bitbucket's JVM so Atlassian application links can easily
  be created

# Usage

## Prerequisites

### Database

Make sure you have a
[supported database](https://confluence.atlassian.com/bitbucket/connecting-bitbucket-to-an-external-database-289276815.html)
available either as a container or standalone.

### `NGINX_UNIT_HOSTS` Considerations

It is important that the value of your `NGINX_UNIT_HOSTS` environment variable is set to a single value and doesn't
include wildcards or regular expressions as this value will be used by Bitbucket to determine the hostname.

## Configuration

It is highly recommended that you use container orchestration software such as
[Docker Compose](https://www.docker.com/products/docker-compose) when using this NGINX Host unit as several Docker
containers are required for operation.  This guide will assume that you are using Docker Compose.  Additionally, we
will use the [official PostgreSQL Docker container](https://hub.docker.com/_/postgres/) for our database.

To begin, start with a basic `docker-compose.yml` file as described in the
[NGINX Host configuration guide](https://github.com/handcraftedbits/docker-nginx-host#configuration).  Then, add a
service for the database (named `db-bitbucket`) and the NGINX Host Bitbucket unit (named `bitbucket`):

```yaml
bitbucket:
  image: handcraftedbits/nginx-unit-bitbucket
  environment:
    - NGINX_UNIT_HOSTS=mysite.com
    - NGINX_URL_PREFIX=/bitbucket
  links:
    - db-bitbucket
  ports:
    - "7999:7999"
  volumes:
    - /home/me/bitbucket:/opt/data/bitbucket
  volumes_from:
    - data

db-bitbucket:
  image: postgres
  environment:
    - POSTGRES_USER=user
    - POSTGRES_PASSWORD=password
    - POSTGRES_DB=bitbucket
  volumes:
    /home/me/db-bitbucket:/var/lib/postgresql/data
```

Observe the following:

* We create a link in `bitbucket` to `db-bitbucket` in order to allow Bitbucket to connect to our database.
* We mount `/opt/data/bitbucket` using the local directory `/home/me/bitbucket`.  This is the directory where Bitbucket
  stores its data.
* As with any other NGINX Host unit, we mount the volumes from our
  [NGINX Host data container](https://github.com/handcraftedbits/docker-nginx-host-data), in this case named `data`.
* Though not required, we bind the local port `7999` to the `bitbucket` container's port `7999` in order to expose
  [Git over SSH](https://confluence.atlassian.com/bitbucketserver/enabling-ssh-access-to-git-repositories-in-bitbucket-server-776640358.html).

For more information on configuring the PostgreSQL container, consult its
[documentation](https://hub.docker.com/_/postgres/).

Finally, we need to create a link in our NGINX Host container to the `bitbucket` container in order to proxy Bitbucket.
Here is our final `docker-compose.yml` file:

```yaml
version: '2'

services:
  bitbucket:
    image: handcraftedbits/nginx-unit-bitbucket
    environment:
      - NGINX_UNIT_HOSTS=mysite.com
      - NGINX_URL_PREFIX=/bitbucket
    links:
      - db-bitbucket
    ports:
      - "7999:7999"
    volumes:
      - /home/me/bitbucket:/opt/data/bitbucket
    volumes_from:
      - data

  data:
    image: handcraftedbits/nginx-host-data

  db-bitbucket:
    image: postgres
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=bitbucket
    volumes:
      /home/me/db-bitbucket:/var/lib/postgresql/data

  proxy:
    image: handcraftedbits/nginx-host
    links:
      - bitbucket
    ports:
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
      - /home/me/dhparam.pem:/etc/ssl/dhparam.pem
    volumes_from:
      - data
```

This will result in making a Bitbucket instance available at `https://mysite.com/bitbucket`.

## Running the NGINX Host Bitbucket Unit

Assuming you are using Docker Compose, simply run `docker-compose up` in the same directory as your
`docker-compose.yml` file.  Otherwise, you will need to start each container with `docker run` or a suitable
alternative, making sure to add the appropriate environment variables and volume references.

When configuring Bitbucket, be sure to select `PostgreSQL` as your database, `db-bitbucket` as the database hostname,
and `5432` as the database port if you configured your database according to the previous section.

# Reference

## Environment Variables

Please see the NGINX Host [documentation](https://github.com/handcraftedbits/docker-nginx-host#units) for information
on the environment variables understood by this unit.
