# AI Core Configuration

`defaults.yaml` captures conservative, reproducible settings for the AI Core.
It is safe to copy this file into `/etc/aetheros/ai-core.yaml` and override
values for local experimentation.

## Translator
- `implementation`: either `rule_based` or `model_assisted` when a model runner
  is available.
- `safety_level`: `restricted` enforces confirmation on potentially disruptive
  commands; `unrestricted` executes trusted actions immediately.
- `verbs`: curated phrases that the rule-based translator can execute without
  consulting a model.

## Model runner
- `runner`: `shell` invokes a local CLI such as `llama.cpp`; `http` targets a
  JSON API endpoint for generation.
- `command`: executable to launch for `shell` runner.
- `model_path`: path to a local weights file when using CLI runners.
- `timeout_seconds`: maximum time to wait for a completion.
- `working_directory`: directory used to store cache or model assets.
- `extra_env`: optional environment variables to inject into the runner.

## Sandbox
- `base_workdir`: isolated working directory prepared per command batch.
- `allowed_binaries`: allowlist enforced by the sandbox before execution.
- `allow_network`: toggles outbound network access inside the sandbox.
- `memory_limit_mb` and `cpu_shares`: resource controls applied when wrappers
  such as bubblewrap or firejail are available.

## Logging
- `level`: standard logging level string.
- `json`: enable JSON-formatted logs for easier ingestion by services.
- `path`: default location for file-based logs when enabled by services.

## Telemetry
- `enabled`: toggles event emission entirely.
- `redact_environment`: removes sensitive environment variables from events.
- `max_event_rate_per_minute`: prevents log storms from misbehaving components.
- `sinks`: supported sinks include `stdout`, `file`, or future service relays.
