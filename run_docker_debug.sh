docker run -it --name http-proxy --rm --publish 80:80 --publish 443:443 --network service_net --add-host "host:172.18.0.1" http-proxy
