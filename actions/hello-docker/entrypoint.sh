#!/bin/sh -l
# Inputs arrive as INPUT_<UPPERCASED NAME> environment variables — exactly
# like JavaScript actions. Outputs go to the file $GITHUB_OUTPUT points at,
# which the runner mounts into the container.

name="${INPUT_NAME:-world}"
greeting="Hello, ${name}, from a Docker container action!"

echo "${greeting}"
echo "greeting=${greeting}" >> "$GITHUB_OUTPUT"
