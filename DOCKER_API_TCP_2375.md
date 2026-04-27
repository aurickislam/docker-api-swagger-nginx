# Expose Docker API on TCP Port 2375

## Problem
Docker Desktop on macOS doesn't natively support TCP binding in `daemon.json` because the Docker daemon runs inside a VM. The standard Linux approach doesn't work directly.

## Solution: Use `socat` in a Container

We use a containerized `socat` tool to forward TCP port 2375 to the Docker Unix socket (`/var/run/docker.sock`).

### Quick Start

Run this command to expose the Docker API on TCP port 2375:

```bash
docker run --rm -p 2375:2375 -v /var/run/docker.sock:/var/run/docker.sock alpine/socat TCP-LISTEN:2375,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock
```

### Verify It Works

In another terminal, test the API:

```bash
curl http://localhost:2375/version
```

You should see JSON output with Docker version information.

## Run as Background Service

To keep the forwarding running while you work, start it as a background job:

```bash
docker run --rm -d -p 2375:2375 -v /var/run/docker.sock:/var/run/docker.sock alpine/socat TCP-LISTEN:2375,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock
```

Get the container ID and verify it's running:

```bash
docker ps
```

### Stop the Background Service

```bash
docker stop $(docker ps -q -f ancestor=alpine/socat)
```

Or use the specific container ID:

```bash
docker stop <container_id>
```

## How It Works

1. **`docker run`** — Starts a container from `alpine/socat` image
2. **`--rm`** — Automatically removes the container when it stops
3. **`-p 2375:2375`** — Publishes TCP port 2375 from the container to your host
4. **`-v /var/run/docker.sock:/var/run/docker.sock`** — Mounts the Docker socket from the host into the container
5. **`socat` command** — Listens on TCP port 2375 and forwards all connections to the Unix socket

### What `socat` Does

```
TCP-LISTEN:2375,reuseaddr,fork  →  UNIX-CONNECT:/var/run/docker.sock
```

- `TCP-LISTEN:2375` — Listen on TCP port 2375
- `reuseaddr` — Allow port reuse without TIME_WAIT delay
- `fork` — Handle multiple concurrent connections
- `UNIX-CONNECT:/var/run/docker.sock` — Forward to the Docker daemon socket

## Use Cases

- **Remote Docker access**: Access Docker API from scripts or tools
- **Docker client over TCP**: Configure Docker CLI to use TCP instead of socket
- **CI/CD pipelines**: Connect Docker builders or agents to the API
- **Container orchestration**: Tools like Kubernetes or Swarm that need TCP access

## Configure Docker Client to Use TCP

To make Docker CLI use TCP port 2375 instead of the socket:

```bash
export DOCKER_HOST=tcp://localhost:2375
docker ps
```

Or permanently in your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
export DOCKER_HOST=tcp://localhost:2375
```

## Security Warning

⚠️ **TCP port 2375 is not encrypted**. This is suitable for:
- Local development only
- Trusted networks only

For production, use TLS-secured port 2376 or restrict access via firewall rules.

## Troubleshooting

### Port 2375 already in use

```bash
lsof -i :2375
```

Kill the process or use a different port:

```bash
docker run --rm -p 2376:2375 -v /var/run/docker.sock:/var/run/docker.sock alpine/socat TCP-LISTEN:2375,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock
```

Then use `tcp://localhost:2376`.

### Connection refused

- Verify the socat container is running: `docker ps`
- Verify Docker Desktop is running: `docker info`
- Wait a few seconds for the container to start and listen

### Permission denied on socket

Ensure Docker Desktop is running and you have permission to access `/var/run/docker.sock`.
