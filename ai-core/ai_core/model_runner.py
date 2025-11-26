"""Local model runner integration for the AI Core."""

from __future__ import annotations

import json
import logging
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Optional

import requests

logger = logging.getLogger(__name__)


@dataclass
class ModelRunnerConfig:
    """Configuration for interacting with a local model backend."""

    runner: str = "shell"
    command: str = "llama.cpp"
    model_path: Optional[str] = None
    endpoint: Optional[str] = None
    timeout_seconds: int = 45
    working_directory: str = "/opt/aetheros/models"
    extra_env: Dict[str, str] = None

    def __post_init__(self) -> None:
        if self.extra_env is None:
            self.extra_env = {}


class LocalModelRunner:
    """Routes prompts to a local model via subprocess or HTTP."""

    def __init__(self, config: ModelRunnerConfig):
        self.config = config

    def generate(self, prompt: str) -> str:
        """Generate text from the configured backend.

        When ``runner`` is ``shell``, a subprocess is invoked with JSON input
        on stdin to simplify integration with llama.cpp or similar CLIs. When
        ``runner`` is ``http``, a POST request with a ``prompt`` body is sent to
        the configured ``endpoint``.
        """

        if self.config.runner == "shell":
            return self._generate_shell(prompt)
        if self.config.runner == "http":
            return self._generate_http(prompt)
        raise ValueError(f"Unsupported runner: {self.config.runner}")

    def _generate_shell(self, prompt: str) -> str:
        command_parts = [self.config.command]
        if self.config.model_path:
            command_parts.extend(["--model", self.config.model_path])

        env = {**self.config.extra_env, **{}}
        logger.debug("Executing local model", extra={"command": command_parts})

        proc = subprocess.run(
            command_parts,
            input=json.dumps({"prompt": prompt}),
            text=True,
            capture_output=True,
            cwd=self.config.working_directory,
            env=env or None,
            timeout=self.config.timeout_seconds,
            check=False,
        )

        if proc.returncode != 0:
            logger.warning(
                "Model runner exited non-zero", extra={"code": proc.returncode, "stderr": proc.stderr}
            )
        output = proc.stdout.strip() or proc.stderr.strip()
        return output

    def _generate_http(self, prompt: str) -> str:
        if not self.config.endpoint:
            raise ValueError("HTTP model runner requires an endpoint")

        response = requests.post(
            self.config.endpoint,
            json={"prompt": prompt},
            timeout=self.config.timeout_seconds,
        )
        response.raise_for_status()

        payload = response.json()
        if isinstance(payload, dict) and "completion" in payload:
            return str(payload["completion"])
        return response.text

    def ensure_workdir(self) -> None:
        """Create working directory for caching models or prompts."""

        path = Path(self.config.working_directory)
        path.mkdir(parents=True, exist_ok=True)

