#!/bin/python3
import sys
import subprocess
from abc import ABC, abstractmethod
from typing import Optional, Tuple


def log(message: str):
    log_file_path = ".gitfilters/clean_log.txt"

    with open(log_file_path, "a+") as log_file:
        log_file.write(f"{message}\n")


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


def delete_starts_with(content: list[str], phrases: list[str]) -> list[str]:
    out = []

    for line in content:
        found = False
        for phrase in phrases:
            if phrase in line:
                found = True
                break
        if found:
            continue
        out.append(line)

    return out


def return_if_modified(before: list[str], after: list[str]) -> Optional[list[str]]:
    return None if len(before) == len(after) else after


def is_empty_line(line: str) -> bool:
    return len(line.strip()) < 1


def get_paragraph_delimitation(
    content: list[str], title: str
) -> Optional[Tuple[int, int]]:
    start = 0
    end = len(content)
    found = False
    for idx, line in enumerate(content):
        if line.startswith(title):
            start = idx
            found = True
        if found and is_empty_line(line):
            end = idx
            break

    return None if not found else (start, end)


def replace_paragraph_with_original(
    original: list[str], modified: list[str], title: str
) -> list[str]:
    o_found = get_paragraph_delimitation(original, title)
    m_found = get_paragraph_delimitation(modified, title)
    if not o_found or not m_found:
        return modified
    (o_start, o_end) = o_found
    (m_start, m_end) = m_found

    return modified[:m_start] + original[o_start:o_end] + modified[m_end:]


def get_original_content(filename: str) -> Optional[list[str]]:
    try:
        result = subprocess.run(
            ["git", "show", "HEAD:" + filename],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.splitlines()
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        return None


class Rule(ABC):
    @abstractmethod
    def apply(self, filename: str, content: list[str]) -> list[str] | None:
        pass


class RuleGTKRC(Rule):
    def apply(self, filename: str, content: list[str]) -> list[str] | None:
        if "gtkrc" not in filename:
            log("Nope")
            return None
        original = get_original_content(filename)
        if not original:
            return None
        return replace_paragraph_with_original(
            original, content, "# created by KDE Plasma"
        )


class RuleKDED5RC(Rule):
    def apply(self, filename: str, content: list[str]) -> list[str] | None:
        if "kded5rc" not in filename:
            return None
        original = get_original_content(filename)
        if not original:
            return None
        return replace_paragraph_with_original(
            original, content, "[PlasmaBrowserIntegration]"
        )


class RuleKwinRC(Rule):
    def apply(self, filename: str, content: list[str]) -> list[str] | None:
        if "kwinrc" not in filename:
            return None
        original = get_original_content(filename)
        if not original:
            return None
        return replace_paragraph_with_original(original, content, "[Desktops]")


def main():
    rules = [RuleGTKRC(), RuleKDED5RC(), RuleKwinRC()]
    log("Start clean script")
    if len(sys.argv) != 2:
        log("ERROR: Missing file name")
        return

    filename = sys.argv[1]
    content = sys.stdin.read().splitlines()
    output = content

    for rule in rules:
        result = rule.apply(filename, content)
        if result is not None:
            output = result
            log(f"Rule for {filename} applied succesfully")
            break

    sys.stdout.writelines(f"{line}\n" for line in output)
    sys.stdout.close()


main()
