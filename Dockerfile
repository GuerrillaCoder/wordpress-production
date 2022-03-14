FROM wordpress:php7.4-fpm

RUN apt update && apt install htop openssh-server libxml2-dev libmemcached-tools memcached zlib1g-dev libpq-dev libmemcached-dev vim -y \
    && echo '' | pecl install memcached && docker-php-ext-enable memcached 

RUN echo 'Port 			2222\n\
ListenAddress 		0.0.0.0\n\
LoginGraceTime 		180\n\
X11Forwarding 		yes\n\
Ciphers aes128-cbc,3des-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr\n\
MACs hmac-sha1,hmac-sha1-96\n\
StrictModes 		yes\n\
SyslogFacility 		DAEMON\n\
PasswordAuthentication 	yes\n\
PermitEmptyPasswords 	no\n\
PermitRootLogin 	yes\n\
Subsystem sftp internal-sftp\n\
AllowUsers www-data root' > /etc/ssh/sshd_config

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN chsh -s /bin/bash www-data

EXPOSE 2222
EXPOSE 443

COPY memcached/memcached.conf /etc/memcached.conf
COPY php/ /usr/local/etc/

ENTRYPOINT service ssh start && service memcached start && echo "root:$SSH_PASSWORD" | chpasswd && echo "www-data:$SSH_PASSWORD" | chpasswd && docker-entrypoint.sh php-fpm
