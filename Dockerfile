FROM ubuntu:latest

COPY image_src/scripts/ /usr/bin/
COPY image_src/templates/ /app/init/

RUN apt update && apt install -y bash openssl iptables openvpn
RUN touch /var/log/openvpn/openvpn.log

WORKDIR /etc/openvpn

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
CMD ["run"]
