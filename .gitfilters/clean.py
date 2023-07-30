#!/bin/python3
import sys
from abc import ABC, abstractmethod
from typing import Optional


def delete_paragraph(content: list[str], phrase: str) -> list[str]:
    start = len(content)
    end = start
    found = False
    for idx, line in enumerate(content):
        if phrase in line:
            start = idx
            found = True
        if found and len(line) < 2:
            end = idx + 1
            break

    return content[:start] + content[end:]


def return_if_modified(before: list[str], after: list[str]) -> Optional[list[str]]:
    return None if len(before) == len(after) else after


class Rule(ABC):
    @abstractmethod
    def apply(self, content: list[str]) -> list[str] | None:
        pass


class RuleGTKRC(Rule):
    def apply(self, content: list[str]) -> list[str] | None:
        c1 = delete_paragraph(content, "# created by KDE Plasma")
        return return_if_modified(content, c1)


class RuleKDED5RC(Rule):
    def apply(self, content: list[str]) -> list[str] | None:
        c1 = delete_paragraph(content, "[PlasmaBrowserIntegration]")

        return return_if_modified(content, c1)


class RuleKwinRC(Rule):
    def apply(self, content: list[str]) -> list[str] | None:
        c1 = delete_paragraph(content, "[$Version]")
        c2 = delete_paragraph(c1, "[Desktops]")

        return return_if_modified(content, c2)


def main():
    rules = [RuleGTKRC(), RuleKDED5RC(), RuleKwinRC()]

    content = sys.stdin.readlines()
    output = content

    for rule in rules:
        result = rule.apply(content)
        if result is not None:
            output = result
            break

    sys.stdout.writelines(output)


main()
