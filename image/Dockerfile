FROM ubuntu:latest

COPY scripts/ /usr/bin/
COPY templates/ /app/init/

RUN apt update && apt install -y bash openssl iptables openvpn
RUN touch /var/log/openvpn/openvpn.log

WORKDIR /etc/openvpn

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
CMD ["run"]
