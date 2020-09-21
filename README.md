# Getting started

1. Adjust mounts in docker-compose.yml
2. Set `command: init` in docker-compose.yml to initialize the folder structure
3. Start once with `docker-compose up`
4. Set `command: create dh 2048` (or a different key size) in docker-compose.yml to create a DH key.
5. Start once with `docker-compose up`
6. Set `command: create tls-key` in docker-compose.yml to create a TLS crypt key.
7. Start once with `docker-compose up`
8. Move CA and server certs to the corresponding folder in `<mountpoint>/certs/server/`. The server files must be named `server.crt` and `server.key`. The CA cert must be named `ca.crt`. They need to be PEM-formatted.
9. Move the client certs to `<mountpoint>/certs/clients/`. The cert must be named `<cn>.crt` and the key `<cn>.key`.
10. Set `command: create client-config` in docker-compose.yml to generate a .ovpn file, that is needed by clients to be able to connect to the server.
11. Start once with `docker-compose up`
12. Finally, delete the `command` instruction from docker-compose.yml.
13. Run openvpn detached with `docker-compose up -d`.

You're done :)