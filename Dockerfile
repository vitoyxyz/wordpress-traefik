FROM wordpress:latest

RUN printf "\n \n" | pecl install redis && docker-php-ext-enable redis
RUN /etc/init.d/apache2 restart

RUN chown -R www-data:www-data /var/www
RUN find /var/www/ -type d -exec chmod 0755 {} \;
RUN find /var/www/ -type f -exec chmod 644 {} \; 
