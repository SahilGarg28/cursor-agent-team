#!/usr/bin/env bash
set -euo pipefail

SKILL_SRC="$(cd "$(dirname "$0")/skill" && pwd)"
AGENTS_SRC="$(cd "$(dirname "$0")/agents" && pwd)"
SKILL_DEST="${HOME}/.cursor/skills/agent-team"
AGENTS_DEST="${HOME}/.cursor/agents"

echo "Agent Team — install"
echo ""
echo "This will copy:"
echo "  ${SKILL_SRC}/  →  ${SKILL_DEST}/"
echo "  ${AGENTS_SRC}/*.md  →  ${AGENTS_DEST}/"
echo ""
read -r -p "Continue? [y/N] " reply
case "${reply}" in
  [yY]|[yY][eE][sS]) ;;
  *) echo "Aborted."; exit 0 ;;
esac

mkdir -p "${SKILL_DEST}" "${AGENTS_DEST}"

cp -R "${SKILL_SRC}/." "${SKILL_DEST}/"
cp "${AGENTS_SRC}"/team-*.md "${AGENTS_DEST}/"

echo ""
echo "Installed."
echo "  Skill:  ${SKILL_DEST}/"
echo "  Agents: ${AGENTS_DEST}/team-{executor,validator,qa,manager}.md"
echo ""
echo "Try: /agent-team <your task>"
