FROM node:9

# system
RUN apt-get update
RUN apt-get install -y supervisor nginx-extras sudo

# app
ENV NODE_ENV production
ENV SHARED_DIR /var/www/shared
WORKDIR /usr/src/app

RUN \
  chown -R www-data:www-data /var/lib/nginx && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  rm /etc/nginx/sites-enabled/default

RUN mkdir -p /var/www/shared
RUN chmod -R 2770 /var/www/shared
RUN chown -R www-data:www-data /var/www/
# RUN sudo -u www-data umask 0002

COPY package*.json /tmp/
RUN cd /tmp && npm --production=false install
RUN cp -a /tmp/node_modules ./

COPY nginx/api.conf /etc/nginx/sites-enabled
COPY nginx/static.conf /etc/nginx/sites-enabled/
COPY supervisor.conf /etc/supervisor/conf.d/

COPY . ./
RUN chown -R www-data:www-data ./
VOLUME /var/www/shared

EXPOSE 80 443
CMD ["/usr/bin/supervisord"]
