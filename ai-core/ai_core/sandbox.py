"""Sandbox executor utilities for AI Core."""

from __future__ import annotations

import os
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Sequence


@dataclass
class SandboxConfig:
    """Constraints for command execution."""

    base_workdir: str = "/tmp/aetheros-sandbox"
    allowed_binaries: Sequence[str] = ("ls", "cat", "echo", "uname", "df")
    allow_network: bool = False
    memory_limit_mb: int = 512
    cpu_shares: int = 512


class ExecutorSandbox:
    """Prepare sandboxed execution environments for translated commands."""

    def __init__(self, config: SandboxConfig):
        self.config = config
        Path(self.config.base_workdir).mkdir(parents=True, exist_ok=True)

    def _binary_allowed(self, command: Sequence[str]) -> bool:
        executable = os.path.basename(command[0])
        return executable in self.config.allowed_binaries

    def build_command(self, command: Sequence[str]) -> List[str]:
        """Build a sandbox-enforced command list.

        Uses bubblewrap or firejail when present; otherwise falls back to a
        trimmed environment invocation. The method ensures the requested binary
        is allowlisted.
        """

        if not self._binary_allowed(command):
            raise PermissionError(f"Command `{command[0]}` is not allowlisted")

        sandbox_bin = shutil.which("bwrap") or shutil.which("firejail")
        if sandbox_bin:
            wrapped = self._wrap_with_isolation(sandbox_bin, command)
        else:
            wrapped = [command[0], *command[1:]]
        return wrapped

    def _wrap_with_isolation(self, sandbox_bin: str, command: Sequence[str]) -> List[str]:
        workdir = Path(self.config.base_workdir)
        workdir.mkdir(parents=True, exist_ok=True)

        if os.path.basename(sandbox_bin) == "bwrap":
            flags = [
                sandbox_bin,
                "--unshare-net" if not self.config.allow_network else "",
                "--ro-bind", "/usr", "/usr",
                "--ro-bind", "/bin", "/bin",
                "--ro-bind", "/lib", "/lib",
                "--ro-bind", "/lib64", "/lib64",
                "--dir", str(workdir),
                "--chdir", str(workdir),
                "--die-with-parent",
                "--new-session",
                "--",
            ]
            flags = [flag for flag in flags if flag]
        else:
            flags = [
                sandbox_bin,
                "--quiet",
                "--private",
                "--private-tmp",
                "--net=none" if not self.config.allow_network else "",
                f"--cpu={self.config.cpu_shares}",
                f"--rlimit-as={self.config.memory_limit_mb}M",
                "--",
            ]
            flags = [flag for flag in flags if flag]

        return [*flags, *command]

    def run(self, command: Sequence[str], environment: Dict[str, str] | None = None) -> subprocess.CompletedProcess:
        full_command = self.build_command(command)
        env = {"PATH": "/usr/bin:/bin"}
        if environment:
            env.update(environment)
        return subprocess.run(
            full_command,
            text=True,
            capture_output=True,
            cwd=self.config.base_workdir,
            env=env,
            check=False,
        )

    def describe(self) -> Dict[str, str]:
        """Return a description of the active sandbox constraints."""

        return {
            "base_workdir": self.config.base_workdir,
            "allowed_binaries": ",".join(sorted(self.config.allowed_binaries)),
            "network": "enabled" if self.config.allow_network else "disabled",
            "memory_limit_mb": str(self.config.memory_limit_mb),
            "cpu_shares": str(self.config.cpu_shares),
        }

