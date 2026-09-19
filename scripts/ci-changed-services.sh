#!/bin/bash
# Works out which services a CI run should deploy and prints them, space
# separated. On workflow_dispatch that is REQUESTED (or everything, for "all");
# on push it is the service directories touched between BEFORE and GITHUB_SHA.
#
# Writes the list to GITHUB_OUTPUT as "services" when running under Actions.
set -euo pipefail

all='jellyfin media nginx-proxy-manager pihole stirling-pdf'

if [ "${GITHUB_EVENT_NAME:-}" = workflow_dispatch ]; then
    if [ "${REQUESTED:-all}" = all ]; then
        services=$all
    else
        services=${REQUESTED}
    fi
else
    before=${BEFORE:-}
    if [ -n "$before" ] && git cat-file -e "$before^{commit}" 2> /dev/null; then
        range="$before..${GITHUB_SHA}"
    else
        # First push on a branch, or a force push: fall back to the last commit.
        range='HEAD~1..HEAD'
    fi
    services=$(git diff --name-only "$range" -- services | awk -F/ 'NF > 2 { print $2 }' | sort -u)
fi

services=$(echo $services)
[ -n "${GITHUB_OUTPUT:-}" ] && echo "services=$services" >> "$GITHUB_OUTPUT"
echo "Deploying: ${services:-nothing}"
