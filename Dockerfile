# nginx:1.13.x
# Debian 9
FROM nginx:1.13

RUN mkdir -p /spool/nginx/cache

COPY nginx-config/ /etc/nginx/

RUN cd /var/log/nginx && \
    mkdir $(ls /etc/nginx/sites-enabled)


# Static HTML content (pending migration to a default-backend container)
COPY htdocs/ /usr/share/nginx/html/

# Cert input
VOLUME /etc/letsencrypt


# This differs from the parent image's CMD in that e.g. it lacks a daemon flag
CMD ["nginx"]
