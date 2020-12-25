FROM amazonlinux:2

WORKDIR /tmp

# Update packages
RUN yum -y update
RUN yum -y install procps vim systemd yum-utils unzip wget sudo git jq

# Install httpd
RUN yum install -y httpd
RUN systemctl enable httpd
ADD ./docker/httpd.conf /etc/httpd/conf/httpd.conf
EXPOSE 80

# Set .bashrc
ADD ./docker/.bashrc /root/.bashrc

# Install PHP
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN yum-config-manager --enable remi-php72
RUN sed -i -e "s/priority=10/priority=99/g" /etc/yum.repos.d/amzn2-core.repo
RUN yum install -y --enablerepo=remi,remi-php73 php php-devel php-mbstring php-pdo php-gd php-xml php-mcrypt php-zip php-mysql

# Install MySQL
RUN yum -y localinstall http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
RUN yum -y install mysql-community-server
RUN systemctl enable mysqld

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

RUN curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
RUN yum install -y --enablerepo=nodesource nodejs
RUN curl https://intoli.com/install-google-chrome.sh | bash
RUN npm install -g selenium-side-runner
RUN npm install -g chromedriver --unsafe-perm=true --allow-root

WORKDIR /var/www/html/scouter-github-laravel
COPY ./docker/init_app.sh /root
RUN chmod +x /root/init_app.sh

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
