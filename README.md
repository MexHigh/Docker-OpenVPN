# Getting started

1. Adjust mounts in docker-compose.yml
2. Set the users and their passwords in the users.conf file. Connecting users will be promted to enter them on connect.
3. Set `command: init` in docker-compose.yml to initialize the folder structure
4. Start once with `docker-compose up`
5. Set `command: create dh 2048` (or a different key size) in docker-compose.yml to create a DH key.
6. Start once with `docker-compose up`
7. Set `command: create tls-key` in docker-compose.yml to create a TLS crypt key.
8. Start once with `docker-compose up`
9. Move CA and server certs to the corresponding folder in `<mountpoint>/certs/server/`. The server files must be named `server.crt` and `server.key`. The CA cert must be named `ca.crt`. They need to be PEM-formatted.
10. Move the client certs to `<mountpoint>/certs/clients/`. The cert must be named `<cn>.crt` and the key `<cn>.key`.
11. Set `command: create client-config` in docker-compose.yml to generate a .ovpn file, that is needed by clients to be able to connect to the server.
12. Start once with `docker-compose up`
13. Finally, delete the `command` instruction from docker-compose.yml.
14. Run openvpn detached with `docker-compose up -d`.

You're done :)