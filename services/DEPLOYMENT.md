# Service Deployment and Operations

This guide describes how to deploy the AI Core, telemetry agent, and health
monitor onto a Mint-based system as part of the AetherOS remaster.

## Prerequisites
- Create a dedicated service account for the stack:
  ```bash
  sudo useradd --system --home /opt/aetheros --shell /usr/sbin/nologin aetheros
  sudo install -d -o aetheros -g aetheros -m 0755 /opt/aetheros/services/bin
  ```
- Install Python 3 with the `requests` dependency for the AI Core HTTP client
  path (the server only uses the standard library).
- Ensure `/var/log/aetheros` and `/var/lib/aetheros/telemetry` are writable by
  the `aetheros` account:
  ```bash
  sudo install -d -o aetheros -g aetheros -m 0755 /var/log/aetheros
  sudo install -d -o aetheros -g aetheros -m 0755 /var/lib/aetheros/telemetry
  ```

## Installing binaries and units
1. Copy the service entrypoints into place:
   ```bash
   sudo cp services/bin/aetheros-* /opt/aetheros/services/bin/
   sudo chown aetheros:aetheros /opt/aetheros/services/bin/aetheros-*
   sudo chmod 0755 /opt/aetheros/services/bin/aetheros-*
   ```
2. Install systemd unit templates:
   ```bash
   sudo cp services/systemd/aetheros-*.service /etc/systemd/system/
   sudo cp services/systemd/aetheros-*.timer /etc/systemd/system/
   sudo systemctl daemon-reload
   ```

## Enabling services
- Start the AI Core and telemetry agents immediately and on boot:
  ```bash
  sudo systemctl enable --now aetheros-ai-core.service aetheros-telemetry.service
  ```
- Turn on scheduled health checks:
  ```bash
  sudo systemctl enable --now aetheros-healthcheck.timer
  ```
- Inspect status at any time with `systemctl status aetheros-ai-core.service` and
  `systemctl status aetheros-telemetry.service`.

## Logs, telemetry, and metrics collection
- The AI Core writes structured logs to the journal and
  `/var/log/aetheros/ai-core.log`. The telemetry agent writes to
  `/var/log/aetheros/telemetry.log`.
- Telemetry events are appended to
  `/var/lib/aetheros/telemetry/events.log`; the telemetry agent converts those
  into Prometheus counters stored in
  `/var/lib/aetheros/telemetry/metrics.prom`.
- Prometheus or another scraper can read both `http://localhost:8042/metrics`
  (AI Core request/translation counters) and `http://localhost:8043/metrics`
  (ingest counters and last-event timestamps) without additional exporters.

## Health verification
- The oneshot healthcheck runs every two minutes via
  `aetheros-healthcheck.timer`. Run it manually for troubleshooting:
  ```bash
  sudo /opt/aetheros/services/bin/aetheros-healthcheck
  ```
- Health endpoints are also available directly:
  - AI Core: `curl http://localhost:8042/healthz`
  - Telemetry agent: `curl http://localhost:8043/healthz`
- Any non-zero exit code from the healthcheck will be logged by systemd; use
  `journalctl -u aetheros-healthcheck.service` to review failures.

## Configuration knobs
- Override ports or telemetry paths at the service level by setting environment
  variables in drop-in files under `/etc/systemd/system/aetheros-ai-core.service.d/`.
  Common overrides:
  ```bash
  [Service]
  Environment=AETHEROS_CORE_PORT=18042
  Environment=AETHEROS_TELEMETRY_QUEUE=/var/lib/aetheros/telemetry/events.log
  ```
- The AI Core reads `/etc/aetheros/ai-core.yaml` if present, allowing customized
  command maps, logging destinations, or model runner settings without editing
  the unit files.
