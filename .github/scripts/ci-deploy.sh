#!/bin/bash
# CI entry point: prepares SSH for the job, then hands off to deploy.sh.
#
# Expects DEPLOY_SSH_KEY, SSH_KNOWN_HOSTS and DEPLOY_HOSTS in the environment,
# which the workflow supplies from repository secrets.
set -euo pipefail

script_dir=$(dirname "$(realpath "$0")")
repo_root=$(cd "$script_dir/../.." && pwd)

if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") <service>..." >&2
    exit 1
fi

: "${DEPLOY_SSH_KEY:?must be set}"
: "${SSH_KNOWN_HOSTS:?must be set}"
: "${DEPLOY_HOSTS:?must be set}"

# Logs on a public repository are public. Only whole secret values are masked
# automatically, so mask each host in DEPLOY_HOSTS on its own.
while IFS='=' read -r _ value; do
    [ -n "$value" ] && echo "::add-mask::$value"
done <<< "$DEPLOY_HOSTS"

# Pinned host keys, so a machine answering on the right address is not trusted
# on sight.
mkdir -p ~/.ssh && chmod 700 ~/.ssh
printf '%s\n' "$SSH_KNOWN_HOSTS" > ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts

# "ssh-add -" reads the key from stdin, so it only ever lives in the agent.
eval "$(ssh-agent -s)" > /dev/null
trap 'ssh-agent -k > /dev/null' EXIT
printf '%s\n' "$DEPLOY_SSH_KEY" | ssh-add -

# DEPLOY_HOSTS is an env file; export its variables for deploy.sh to read.
set -a; . <(printf '%s\n' "$DEPLOY_HOSTS"); set +a

"$repo_root/scripts/deploy.sh" "$@"
