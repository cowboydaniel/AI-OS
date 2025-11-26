"""AetherOS AI Core package.

Defines command translation, model integration, and sandboxed execution utilities for the AI Core.
"""

from .command_translation import (
    CommandContext,
    CommandIntent,
    CommandRequest,
    CommandTranslationResult,
    CommandTranslator,
    RuleBasedCommandTranslator,
)
from .model_runner import LocalModelRunner, ModelRunnerConfig
from .sandbox import ExecutorSandbox, SandboxConfig

__all__ = [
    "CommandContext",
    "CommandIntent",
    "CommandRequest",
    "CommandTranslationResult",
    "CommandTranslator",
    "RuleBasedCommandTranslator",
    "LocalModelRunner",
    "ModelRunnerConfig",
    "ExecutorSandbox",
    "SandboxConfig",
]
