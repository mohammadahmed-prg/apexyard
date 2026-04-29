#!/usr/bin/env bash
# Post a markdown file (e.g. a stakeholder update) to a Slack incoming webhook.
#
# Usage:
#   export SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T.../B.../...
#   scripts/post-update-to-slack.sh projects/hook-leads/updates/weekly-2026-04-27.md
#
# The file is sent verbatim as a single Slack message using mrkdwn formatting.
# Slack's mrkdwn is close-but-not-identical to GitHub markdown — headings render
# as plain bold-ish text, tables stay raw. Good enough for digests; not a doc.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <path-to-markdown-file>" >&2
  exit 2
fi

FILE="$1"

if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
  echo "error: SLACK_WEBHOOK_URL is not set" >&2
  echo "create one at https://api.slack.com/apps -> Incoming Webhooks, then export it" >&2
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "error: file not found: $FILE" >&2
  exit 1
fi

PAYLOAD=$(jq -Rs '{text: ., mrkdwn: true}' < "$FILE")

HTTP_CODE=$(curl -sS -o /tmp/slack-post.out -w "%{http_code}" \
  -X POST -H 'Content-Type: application/json' \
  --data "$PAYLOAD" \
  "$SLACK_WEBHOOK_URL")

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "slack post failed (HTTP $HTTP_CODE):" >&2
  cat /tmp/slack-post.out >&2
  exit 1
fi

echo "posted $FILE to Slack (HTTP $HTTP_CODE)"
