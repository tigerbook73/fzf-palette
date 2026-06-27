#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash -n "$ROOT_DIR/installer.sh"
bash -n "$ROOT_DIR/core/dispatcher.sh"
bash -n "$ROOT_DIR/modules/common.sh"
bash -n "$ROOT_DIR/modules/cd.sh"
bash -n "$ROOT_DIR/modules/git.sh"

echo "syntax ok"
