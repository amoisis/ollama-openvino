# Ollama + OpenVINO Docker Image

[![Docker Publish](https://github.com/amoisis/ollama-openvino/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/amoisis/ollama-openvino/actions/workflows/docker-publish.yml)
[![Dependabot Status](https://github.com/amoisis/ollama-openvino/actions/workflows/dependabot.yml/badge.svg)](https://github.com/amoisis/ollama-openvino/actions/workflows/dependabot.yml)

A production-ready Docker image for running [Ollama](https://ollama.com/) with [OpenVINO](https://docs.openvino.ai/latest/index.html) acceleration, designed for Intel GPU/NPU hardware. Includes Traefik labels for reverse proxy integration and is compatible with Docker Compose and Komodo deployments.

---

## Features
- Ollama LLM server with OpenVINO backend
- Intel GPU (iGPU) and NPU (AI Boost) support
- Traefik reverse proxy labels for easy HTTPS routing
- Docker Compose and Komodo compatible
- Persistent model storage via external volume
- Healthcheck and resource limits

## Quick Start

### 1. Build the Image
```sh
docker build -t custom-ollama-openvino:latest .
```

### 2. Run with Docker Compose
Uncomment and adjust the `openwebui` service if needed. Example:
```sh
docker compose up -d ollama
```

### 3. Run Manually
```sh
docker run -d \
  --name ollama \
  --network host \
  --restart unless-stopped \
  --device /dev/dri \
  --device /dev/accel \
  -e OPENVINO_DEVICE=AUTO \
  -v dockerssd:/models \
  custom-ollama-openvino:latest
```

## Environment Variables
- `OPENVINO_DEVICE` (default: `AUTO`): Set to `GPU`, `NPU`, `CPU`, or `AUTO` for device selection.
- `no_proxy`: Set to `localhost,127.0.0.1` for local networking.

## Volumes
- `/models`: Persistent model storage (external Docker volume recommended)

## Traefik Labels
- Pre-configured for HTTPS routing and healthchecks. Adjust hostnames as needed in `compose.yaml`.

## Healthcheck
- Service is checked on port `11434` by default.

## GPU/NPU Support
- Devices `/dev/dri` (GPU) and `/dev/accel` (NPU) must be present and mapped into the container.
- Ensure Intel drivers are installed on the host.

## Komodo Deployment
- Push your image to a registry if Komodo cannot access your local Docker images.
- Reference the image in your Komodo deployment YAML.

## Troubleshooting
- Check container logs: `docker logs ollama`
- Verify device access: `ls /dev/dri /dev/accel` inside the container
- Test OpenVINO: `python -c "from openvino.runtime import Core; print(Core().available_devices)"`
- Port conflicts: Ensure port 11434 is not in use on the host

## License
MIT

---

> Maintained by [amoisislab](https://github.com/amoisislab)
