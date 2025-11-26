# Services Directory

This directory houses service entrypoints, systemd unit templates, and health
checks that keep the AI Core running as a managed background stack.

## Components
- `bin/aetheros-ai-core-service` – HTTP service exposing `/translate`,
  `/healthz`, and `/metrics` endpoints backed by the rule-based command
  translator and local model runner hooks.
- `bin/aetheros-telemetry-agent` – background agent that tails telemetry events
  produced by the AI Core, persists counters to a Prometheus-compatible metrics
  file, and exposes its own health endpoint.
- `bin/aetheros-healthcheck` – oneshot probe that calls the AI Core and telemetry
  health endpoints and returns a non-zero exit code on failure.
- `systemd/aetheros-ai-core.service` – systemd unit template for the AI Core
  HTTP service, including log and runtime directory scaffolding.
- `systemd/aetheros-telemetry.service` – systemd unit template for the telemetry
  agent, ensuring its queue and metrics directories exist before startup.
- `systemd/aetheros-healthcheck.service` and `systemd/aetheros-healthcheck.timer`
  – scheduled health verification that runs every two minutes.

## Running locally
1. Export optional overrides to adjust ports or telemetry paths:
   ```bash
   export AETHEROS_CORE_PORT=8042
   export AETHEROS_TELEMETRY_PORT=8043
   export AETHEROS_TELEMETRY_QUEUE=/tmp/aetheros/telemetry/events.log
   ```
2. Start the AI Core HTTP service:
   ```bash
   python3 services/bin/aetheros-ai-core-service
   ```
3. In another terminal, start the telemetry agent so metrics populate:
   ```bash
   python3 services/bin/aetheros-telemetry-agent
   ```
4. Verify both processes with the healthcheck script:
   ```bash
   python3 services/bin/aetheros-healthcheck
   ```

## Service management
- Copy the `systemd/*.service` and `systemd/*.timer` units to
  `/etc/systemd/system/` and reload systemd with `sudo systemctl daemon-reload`.
- Enable the services and timer on boot:
  ```bash
  sudo systemctl enable --now aetheros-ai-core.service aetheros-telemetry.service
  sudo systemctl enable --now aetheros-healthcheck.timer
  ```
- Logs are written to the journal and rotated files under `/var/log/aetheros/`.
  Metrics and telemetry queues default to `/var/lib/aetheros/telemetry/`.
- The AI Core serves translation requests at `http://localhost:8042/translate`
  and publishes metrics at `http://localhost:8042/metrics`. The telemetry agent
  exposes metrics at `http://localhost:8043/metrics`.

For more deployment detail and operational expectations, see
`services/DEPLOYMENT.md`.
