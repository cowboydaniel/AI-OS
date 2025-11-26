# AI Core Directory

Core logic for command translation, model runtime integration, and execution
sandboxing lives here. Interfaces are written in Python to keep translation and
execution steps testable while we iterate on the Mint remaster.

## Components
- `ai_core/command_translation.py` – dataclasses and a rule-based translator
  that can convert common natural-language requests into allowlisted shell
  commands.
- `ai_core/model_runner.py` – hooks for invoking a local model via CLI or HTTP;
  the runner accepts JSON prompts and returns completions without blocking the
  UI.
- `ai_core/sandbox.py` – sandbox builder that wraps commands with bubblewrap or
  firejail when available and always enforces an allowlist and resource limits.
- `config/defaults.yaml` – reference configuration for translators, model
  runners, sandbox constraints, logging, and telemetry behavior.
- `telemetry.md` – logging and telemetry expectations, including privacy
  redaction rules and performance counters for future services.

## Usage snapshot
```python
from ai_core import (
    CommandRequest,
    RuleBasedCommandTranslator,
    LocalModelRunner,
    ModelRunnerConfig,
    ExecutorSandbox,
    SandboxConfig,
)

translator = RuleBasedCommandTranslator()
request = CommandRequest(text="show system info")
translation = translator.translate(request)

sandbox = ExecutorSandbox(SandboxConfig())
result = sandbox.run(translation.primary_command())
print(result.stdout)
```

Model-assisted translation can be layered on top of the `LocalModelRunner` by
passing translated prompts to the runner and merging the returned command plan
with the allowlisted sandbox rules above.
