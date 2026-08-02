# Multi-stage build for the workshop app (Lab 8 builds and ships this image).
# The app has zero runtime npm dependencies, so the "build" stage only runs
# the build script; in a real project it would also run `npm ci`.
#
# Production hardening notes for attendees:
#   - node:24-alpine is a minimal official base image. In production you would
#     additionally pin the digest, e.g. node:24-alpine@sha256:<digest>.
#   - The final stage runs as the non-root `node` user.

# ---- Stage 1: build ---------------------------------------------------------
FROM node:24-alpine AS build
WORKDIR /app

# CI passes these so the build stamps traceable metadata into build-info.json
ARG GITHUB_SHA
ARG GITHUB_RUN_NUMBER
ENV GITHUB_SHA=$GITHUB_SHA \
    GITHUB_RUN_NUMBER=$GITHUB_RUN_NUMBER

COPY package.json package-lock.json ./
# No runtime deps to install, but keep the step so the pattern is realistic
# and the Docker layer cache demo in Lab 8 has something to cache.
RUN npm ci --ignore-scripts

COPY src ./src
COPY scripts ./scripts
RUN npm run build

# ---- Stage 2: production ----------------------------------------------------
FROM node:24-alpine AS production
ENV NODE_ENV=production
WORKDIR /app

COPY --from=build --chown=node:node /app/dist ./

USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "fetch('http://localhost:3000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "src/server.js"]
