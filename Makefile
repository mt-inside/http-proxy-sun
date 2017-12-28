build:
	docker build . --pull -t http-proxy

run:
	docker run -d --name http-proxy --rm --publish 80:80 --publish 443:443 --volume http-proxy-certs:/etc/letsencrypt --network service_net --add-host "host:172.18.0.1" http-proxy

run-fg:
	docker run -it --name http-proxy --rm --publish 80:80 --publish 443:443 --volume http-proxy-certs:/etc/letsencrypt --network service_net --add-host "host:172.18.0.1" http-proxy

run-shell:
	docker run -it --name http-proxy --rm --publish 80:80 --publish 443:443 --volume http-proxy-certs:/etc/letsencrypt --network service_net --add-host "host:172.18.0.1" http-proxy /bin/sh

exec-shell:
	docker exec -it http-proxy /bin/sh
