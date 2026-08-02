#!/usr/bin/env bash
# Lab 7 helper — downloads and unpacks the GitHub Actions runner agent.
# Run inside a Codespace or Linux machine/container you control.
#
#   ./scripts/runner-setup.sh
#
# It does NOT register the runner: the registration token is personal and
# short-lived, so grab the `./config.sh --url ... --token ...` line from
# YOUR repo's Settings → Actions → Runners → "New self-hosted runner",
# then finish with ./run.sh
set -euo pipefail

ARCH="x64"
case "$(uname -m)" in
  aarch64|arm64) ARCH="arm64" ;;
esac

echo "Looking up the latest runner release..."
LATEST=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | grep -oP '"tag_name":\s*"v\K[0-9.]+' | head -1)
echo "Latest runner version: ${LATEST} (${ARCH})"

mkdir -p actions-runner && cd actions-runner

TARBALL="actions-runner-linux-${ARCH}-${LATEST}.tar.gz"
echo "Downloading ${TARBALL}..."
curl -fsSL -o "${TARBALL}" \
  "https://github.com/actions/runner/releases/download/v${LATEST}/${TARBALL}"

tar xzf "${TARBALL}"
rm "${TARBALL}"

cat <<'EOF'

✅ Runner unpacked into ./actions-runner

Next steps (from YOUR repository — must be PRIVATE, see Lab 7):
  1. Settings → Actions → Runners → New self-hosted runner → Linux
  2. Copy ONLY the ./config.sh line (it contains your short-lived token):
       ./config.sh --url https://github.com/YOU/runner-playground --token XXXX
     When prompted for labels, add: workshop
  3. Start it:  ./run.sh
EOF
