# autossh-docker

Generic Docker-based `autossh` tunnel runner.


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

3. Set `SSH_DIR` to your local `.ssh` directory before starting the container.

   Examples:

   Linux or macOS:

   ```sh
   export SSH_DIR="$HOME/.ssh"
   ```

   PowerShell:

   ```powershell
   $env:SSH_DIR = "$HOME/.ssh"
   ```

   Windows Command Prompt:

   ```cmd
   set SSH_DIR=%USERPROFILE%\.ssh
   ```

4. Edit `docker-compose.yml` and replace the placeholder values:

   - `SSH_TARGET_USER` with your SSH username
   - `SSH_TARGET_HOST` with your SSH host or IP
   - `SSH_TARGET_PORT` if not `22`
   - `SSH_KEY_PATH` with the path inside the container to your mounted key
   - `TUNNELS` with your `-R` and/or `-L` forwarding rules

   The example includes a reverse tunnel that exposes remote port `8777` on all remote interfaces and forwards it to `host.docker.internal:8777` on the Docker host.

5. Make sure your SSH key is mounted read-only. The example uses:

   ```yaml
   volumes:
     - ${SSH_DIR}:/root/.ssh:ro
   ```
   
   This reuses keys from your machine and avoids copying secrets into this repo.

6. Start the container:

   ```sh
   docker compose up -d --build
   ```

7. View logs if needed:

   ```sh
   docker compose logs -f
   ```

## Notes

- `AUTOSSH_MONITOR_PORT=0` disables the dedicated monitoring port and relies on SSH keepalives.
- `host.docker.internal:host-gateway` lets the container reach services running on the Docker host without using host networking.
- Binding a reverse tunnel to `0.0.0.0` usually requires `GatewayPorts yes` or `GatewayPorts clientspecified` on the remote SSH server.
- Set `SSH_STRICT_HOST_KEY_CHECKING=yes` once you have known hosts configured.
- If your SSH server needs additional options, put them in `EXTRA_SSH_ARGS`.

## Stop

```sh
docker compose down
```
