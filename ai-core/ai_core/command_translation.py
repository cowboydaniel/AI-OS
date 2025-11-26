"""Command translation interfaces and rule-based implementation.

The AI Core converts conversational requests into actionable system commands.
This module defines the data structures and a baseline rule-based translator
that can operate without a model while providing hooks for model-assisted
expansion.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, Iterable, List, Optional, Sequence
import re


@dataclass
class CommandContext:
    """Context supplied by the UI or services.

    Attributes:
        working_directory: Directory from which commands should run.
        environment: Environment variables the executor should expose.
        allow_network: Whether network access is permitted for the action.
    """

    working_directory: str = "/home"
    environment: Dict[str, str] = field(default_factory=dict)
    allow_network: bool = False


@dataclass
class CommandIntent:
    """Represents a single action the system should perform."""

    description: str
    command: Sequence[str]
    confidence: float
    requires_confirmation: bool = False
    notes: Optional[str] = None


@dataclass
class CommandRequest:
    """User or UI-provided input to translate."""

    text: str
    context: CommandContext = field(default_factory=CommandContext)
    safety_level: str = "restricted"


@dataclass
class CommandTranslationResult:
    """Result returned by a translator."""

    intents: List[CommandIntent]
    rationale: str
    used_model: Optional[str] = None

    def primary_command(self) -> Optional[Sequence[str]]:
        """Return the highest-confidence command if available."""

        if not self.intents:
            return None
        return max(self.intents, key=lambda intent: intent.confidence).command


class CommandTranslator:
    """Interface for translators.

    Subclasses should implement :meth:`translate` and may override
    :meth:`supported_verbs` to expose known command categories.
    """

    def translate(self, request: CommandRequest) -> CommandTranslationResult:
        raise NotImplementedError

    def supported_verbs(self) -> Iterable[str]:
        return []


class RuleBasedCommandTranslator(CommandTranslator):
    """Deterministic translator using curated patterns.

    This translator is intentionally conservative and only emits commands for
    well-understood verbs. It can be used offline as a bootstrap implementation
    and as a fallback when a local model runner is unavailable.
    """

    def __init__(self, command_map: Optional[Dict[str, Sequence[str]]] = None):
        self.command_map = command_map or {
            "open browser": ["xdg-open", "https://linuxmint.com"],
            "list files": ["ls", "-la"],
            "show system info": ["uname", "-a"],
            "update packages": ["sudo", "apt", "update"],
            "upgrade packages": ["sudo", "apt", "upgrade", "-y"],
            "check disk usage": ["df", "-h"],
        }
        self._pattern_cache: List[tuple[re.Pattern[str], Sequence[str]]] = []
        for phrase, command in self.command_map.items():
            pattern = re.compile(rf"\b{re.escape(phrase)}\b", re.IGNORECASE)
            self._pattern_cache.append((pattern, command))

    def supported_verbs(self) -> Iterable[str]:
        return self.command_map.keys()

    def translate(self, request: CommandRequest) -> CommandTranslationResult:
        normalized = request.text.strip().lower()
        intents: List[CommandIntent] = []
        matched_phrase: Optional[str] = None

        for pattern, command in self._pattern_cache:
            if pattern.search(normalized):
                matched_phrase = pattern.pattern
                intents.append(
                    CommandIntent(
                        description=f"Execute `{command[0]}` based on recognized phrase",
                        command=list(command),
                        confidence=0.92,
                        requires_confirmation=request.safety_level != "unrestricted",
                        notes="Matched deterministic rule",
                    )
                )
                break

        if not intents:
            # Fall back to a conservative suggestion when no rule matches.
            intents.append(
                CommandIntent(
                    description="No deterministic rule matched; propose shell echo",
                    command=["echo", f"Requested: {request.text}"],
                    confidence=0.25,
                    requires_confirmation=True,
                    notes="Fallback safeguard for unrecognized input",
                )
            )

        rationale_parts = [
            "Used rule-based translator; deterministic patterns preferred.",
        ]
        if matched_phrase:
            rationale_parts.append(f"Matched pattern: {matched_phrase}")
        else:
            rationale_parts.append("No direct match; emitted safe echo fallback.")

        return CommandTranslationResult(
            intents=intents,
            rationale=" ".join(rationale_parts),
            used_model=None,
        )
