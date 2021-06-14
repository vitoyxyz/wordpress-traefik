## Introduction

Set-up a Wordpress, Redis and MySql with Traefik reverse proxy, using Docker Compose.

**Prerequisites**

- Ubuntu 20.04 server(or any distro you want)
- [Docker](https://docs.docker.com/engine/install/) & [Docker-Compose](https://docs.docker.com/compose/install/) installed
- [Traefik](https://doc.traefik.io/traefik/getting-started/install-traefik/) installed
- Domain name

## Running the stack

### Clone the repository

```shell
git clone https://github.com/vitoyxyz/wordpress-traefik && cd wordpress-traefik
```

## You need edit

- MYSQL environment PASSWORDS
- TRUSTED_PROXIES(yor traefik container IP)
- Network name of traefik(here is proxy)
- you_domain.com with your own domain name

### Running the stack

```shell
docker-compose up -d
```

```yml
# docker-compose.yml

version: "3.7"

networks:
  proxy:
    external:
      name: proxy

services:
  db:
    image: mysql:5.7
    container_name: your_domain_db
    restart: always
    volumes:
      - wp_database:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_PASSWORD=random_password_123
      - MYSQL_DATABASE=your_domain_database
      - MYSQL_USER=your_domain_user

  wordpress:
    build: .
    container_name: your_domain
    restart: always
    ports:
      - 5050:80
    networks:
      - proxy
      - default
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=your_domain_user
      - WORDPRESS_DB_PASSWORD=random_password_123
      - WORDPRESS_DB_NAME=your_domain_database
      - WORDPRESS_CONFIG_EXTRA=
        define( 'FS_METHOD', direct );
        define( 'WP_REDIS_HOST', 'redis');
        define( 'WP_CACHE_KEY_SALT', 'change_me' );
    volumes:
      - wp:/var/www/html
    depends_on:
      - db
      - redis
    labels:
      - "traefik.enable=true"
      - "traefik.protocol=http"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.your_domain.entrypoints=websecure"
      - traefik.http.routers.your_domain.tls.certresolver=letsencrypt
      - traefik.http.routers.your_domain.rule=Host(`your_domain.com`)

  redis:
    image: redis:6
    restart: always
    ports:
      - "6379:6379"

  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin
    container_name: phpmyadmin
    restart: always
    ports:
      - "8565:80"
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: root
    labels:
      - "traefik.enable=true"
      - "traefik.protocol=http"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.pma_your_domain.entrypoints=websecure"
      - traefik.http.routers.pma_your_domain.tls.certresolver=letsencrypt
      - traefik.http.routers.pma_your_domain.rule=Host(`pma.your_domain.com`)

volumes:
  wp:
  wp_database:
```
