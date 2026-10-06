#Dockerized Diagnostic CLI

A Bash diagnostic tool packaged as a Docker image.

## Requirements

- Docker (with the Compose plugin)

## Setup

```bash
git clone <this-repo-url>
cd assignment-2
chmod +x grade.sh test.sh app/*.sh
docker build -t diagnostic-tool .
```

## Usage

```bash
docker run --rm diagnostic-tool help
docker run --rm diagnostic-tool system
docker run --rm diagnostic-tool disk
docker run --rm diagnostic-tool network example.com
```

With Docker Compose:

```bash
docker compose run --rm diagnostic system
```

## Exit codes

| Code | Meaning                                           |
|------|---------------------------------------------------|
| 0    | Success                                           |
| 1    | Operational failure (e.g. host cannot be resolved) |
| 2    | Invalid command or missing/invalid argument       |

## Testing

```bash
./test.sh     # builds the image and tests help, system, disk, network, invalid input
./grade.sh    # instructor grader
```

## Design notes and assumptions

- Base image: `alpine:3.20`. Only `bash` and `procps-ng` (for `free` and `uptime -p`) are installed.
- The container runs as a non-root user.
- `ENTRYPOINT` is the CLI and `CMD` is `help`, so `docker run diagnostic-tool` prints usage.
- A failed ping does not fail `network`; only a failed DNS resolution does, since ICMP is often blocked.
- `health-check.sh` verifies dependencies and that the CLI runs; it is wired to `HEALTHCHECK`.
- `.dockerignore` keeps `.git`, logs and local files out of the build context.
