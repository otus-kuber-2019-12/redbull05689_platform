FROM nginx:stable
RUN groupadd --gid 1001 otus \
  && useradd --uid 1001 -g root -G sudo --shell /bin/bash -m otus

ADD confd /etc/nginx/conf.d
ADD app /app
RUN sed -i 's/user  nginx/user otus/' /etc/nginx/nginx.conf
RUN chmod -R 777 /var/cache/* && chmod -R 777 /var/run/

WORKDIR /app
RUN chmod -R 777 /app
#USER otus
CMD /usr/sbin/nginx -g 'daemon off;'
