# nginx:1.13.x
# Debian 9
FROM nginx:1.13

COPY nginx-config/ /etc/nginx/

COPY htdocs/ /usr/share/nginx/html/

RUN cd /var/log/nginx && \
    mkdir $(ls /etc/nginx/sites-enabled)

RUN mkdir -p /spool/nginx/cache


COPY cmd.sh /
CMD /cmd.sh
