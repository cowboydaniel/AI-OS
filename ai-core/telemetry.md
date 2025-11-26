# AI Core Telemetry and Logging Expectations

The AI Core collects operational events to support troubleshooting while
respecting user privacy and the principle of least privilege.

## Logging
- Use structured logs that include `request_id`, `translator`, and `sandbox` keys
  when invoking model runners or executing commands.
- Default log level is `INFO`; sensitive paths (sandbox setup, runner failures)
  should log at `WARNING` or higher.
- Avoid logging full command arguments when they include user data. Prefer
  anonymized summaries that reference allowlisted binaries and context flags.
- Logs should be emitted to both stdout and a rotating file when running under
  systemd units, keeping retention small to avoid user data accumulation.

## Telemetry events
- Emit start/stop events for command translation and execution, including
  timing metrics and the safety level chosen.
- Record model runner selection, endpoint, and latency without persisting raw
  prompts or completions unless the user opts in to diagnostics mode.
- Capture sandbox policy decisions: allowlist hits, network toggles, and
  resource limits applied.
- Enforce `max_event_rate_per_minute` from configuration to prevent overloading
  downstream sinks.

## Redaction and privacy
- Strip environment variables, home directories, and usernames from emitted
  payloads. Hash hostnames when telemetry leaves the machine.
- Provide a single configuration flag to disable telemetry entirely.
- Respect per-session opt-out signals sent by the UI layer.

## Operational hooks
- Telemetry modules should expose a `record_event(event_type, payload)` helper
  that validates payload schemas before dispatching to sinks.
- When sinks are unreachable, queue at most a handful of events locally and
  drop the rest; avoid blocking the user experience.
- Expose Prometheus-friendly counters for model invocations, sandbox denials,
  and executor exit codes to feed into future service monitors.
