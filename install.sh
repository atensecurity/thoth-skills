#!/bin/sh
# Install the Thoth agent skills for Codex, and any agent that reads Agent
# Skills from ~/.agents/skills, straight from this repository.
#
#   curl -fsSL https://raw.githubusercontent.com/atensecurity/thoth-skills/main/install.sh | sh
#
# Options:
#   --project           install into ./.agents/skills (this repository only)
#   --dir <path>        install into another skills directory
#   --ref <tag|branch>  install a specific release (default: main)
#   --uninstall         remove the Thoth skills from the target directory
#
# Only the thoth-* skill folders are written or removed; other skills are
# left alone. Codex picks up the skills automatically; restart it if they do
# not appear. Read this script before piping it to sh if you prefer:
#   curl -fsSL https://raw.githubusercontent.com/atensecurity/thoth-skills/main/install.sh
set -eu

repo="atensecurity/thoth-skills"
ref="${THOTH_SKILLS_REF:-main}"
target="${THOTH_SKILLS_DIR:-${HOME}/.agents/skills}"
uninstall=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) target="$(pwd)/.agents/skills" ;;
    --dir) shift; target="${1:?--dir needs a path}" ;;
    --ref) shift; ref="${1:?--ref needs a tag or branch}" ;;
    --uninstall) uninstall=1 ;;
    -h|--help) sed -n '2,18p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "thoth-skills: unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

case "$ref" in
  *[!A-Za-z0-9._/-]*|"") echo "thoth-skills: invalid ref '$ref'" >&2; exit 2 ;;
esac

if [ "$uninstall" -eq 1 ]; then
  removed=0
  for dir in "$target"/thoth-*; do
    [ -d "$dir" ] || continue
    rm -rf "$dir"
    echo "removed $(basename "$dir")"
    removed=1
  done
  [ "$removed" -eq 1 ] || echo "No Thoth skills found in $target"
  exit 0
fi

tmp="$(mktemp -d 2>/dev/null || mktemp -d -t thoth-skills)"
trap 'rm -rf "$tmp"' EXIT INT TERM

archive="https://codeload.github.com/${repo}/tar.gz/${ref}"
fetched=1
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$archive" -o "$tmp/skills.tar.gz" || fetched=0
elif command -v wget >/dev/null 2>&1; then
  wget -q "$archive" -O "$tmp/skills.tar.gz" || fetched=0
else
  echo "thoth-skills: curl or wget is required" >&2
  exit 1
fi
if [ "$fetched" -eq 0 ]; then
  echo "thoth-skills: could not download ref '$ref' from github.com/${repo}" >&2
  exit 1
fi
tar -xzf "$tmp/skills.tar.gz" -C "$tmp"

source_dir="$(find "$tmp" -mindepth 2 -maxdepth 2 -type d -name skills | head -n 1)"
if [ -z "$source_dir" ]; then
  echo "thoth-skills: the download has no skills folder (ref '$ref')" >&2
  exit 1
fi

mkdir -p "$target"
installed=""
for skill in "$source_dir"/thoth-*; do
  [ -f "$skill/SKILL.md" ] || continue
  name="$(basename "$skill")"
  rm -rf "${target:?}/$name"
  cp -R "$skill" "$target/$name"
  installed="$installed $name"
done

if [ -z "$installed" ]; then
  echo "thoth-skills: no skills found in ref '$ref'" >&2
  exit 1
fi

echo "Installed Thoth skills into $target:"
for name in $installed; do echo "  $name"; done
echo
echo "Codex loads them automatically; restart Codex if they don't appear."
echo "Then ask your agent, for example: \"Put my agent's tools behind Thoth.\""
