#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
docker compose -f app.yml logs --tail 500 -f
