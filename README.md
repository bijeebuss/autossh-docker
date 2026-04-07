# autossh-docker

Generic Docker-based `autossh` tunnel runner.

This repo stays generic. It does not include any real SSH keys, hostnames, usernames, or IP addresses.


## Files

- `Dockerfile` - lightweight image with `autossh` and `openssh-client`
- `entrypoint.sh` - builds the `autossh` command from environment variables
- `docker-compose.example.yml` - example Compose setup with placeholders only

## Requirements

- Docker
- Docker Compose
- A reachable SSH server that allows the tunnel(s) you want to create
- An SSH key already present on your machine

## Quick start

1. Change into the folder:

   ```sh
   cd autossh-docker
   ```

2. Copy the example Compose file:

   ```sh
   cp docker-compose.example.yml docker-compose.yml
   ```

3. Create a local `.ssh` folder inside `autossh-docker` before building.

   Example:

   ```sh
   mkdir -p .ssh
   cp /path/to/your/private/key .ssh/id_ed25519
   cp /path/to/your/public/key .ssh/id_ed25519.pub
   cp /path/to/your/known_hosts .ssh/known_hosts
   ```

   Do not commit that folder. It is ignored locally and copied into the image only at build time.

4. Copy the example Compose file and edit it:

   ```sh
   cp docker-compose.example.yml docker-compose.yml
   ```

   Replace the placeholder values:

   - `SSH_TARGET_USER` with your SSH username
   - `SSH_TARGET_HOST` with your SSH host or IP
   - `SSH_TARGET_PORT` if not `22`
   - `SSH_KEY_PATH` with the path to the copied private key inside the container
   - `TUNNELS` with your `-R` and/or `-L` forwarding rules

   The example includes a reverse tunnel that exposes remote port `8777` on all remote interfaces and forwards it to `host.docker.internal:8777` on the Docker host.

5. Build and start the container:

   ```sh
   docker compose up -d --build
   ```

   During build, the Dockerfile copies `.ssh/` into `/root/.ssh` and normalizes permissions before the container starts.

6. View logs if needed:

   ```sh
   docker compose logs -f
   ```

## Notes

- `AUTOSSH_MONITOR_PORT=0` disables the dedicated monitoring port and relies on SSH keepalives.
- `host.docker.internal:host-gateway` lets the container reach services running on the Docker host without using host networking.
- Binding a reverse tunnel to `0.0.0.0` usually requires `GatewayPorts yes` or `GatewayPorts clientspecified` on the remote SSH server.
- SSH files are copied into `/root/.ssh` during image build, and the Dockerfile fixes permissions for the directory, keys, `config`, and `known_hosts`.
- Set `SSH_STRICT_HOST_KEY_CHECKING=yes` once you have known hosts configured.
- If your SSH server needs additional options, put them in `EXTRA_SSH_ARGS`.

## Stop

```sh
docker compose down
```
