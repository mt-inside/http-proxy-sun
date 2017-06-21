FROM nginx

COPY nginx-config/ /etc/nginx/

COPY htdocs/ /usr/share/nginx/html/

RUN cd /var/log/nginx && \
    mkdir $(ls /etc/nginx/sites-enabled)

RUN mkdir -p /spool/nginx/cache
