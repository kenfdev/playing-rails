# =============================================================================
# Default app Dockerfile. Inherits from the team-shared base image.
#
# CUSTOMIZE: Add project-specific dependencies here (language runtimes,
# build tools, client libraries, etc.)
#
# BASE_IMAGE is provided as a build arg by docker-compose.yml.
# Do not change the ARG/FROM lines.
# =============================================================================

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Node + Playwright system dependencies for system tests.
#
# The Rails app uses importmaps, so Node is only needed for Playwright-driven
# system tests (capybara-playwright-driver shells out to `npx playwright`).
# The apt list mirrors `npx playwright install-deps chromium`; baking it in
# means `bin/setup` can run `npx playwright install chromium` without
# --with-deps (which would otherwise need sudo on every fresh container).
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    nodejs \
    libasound2t64 libatk-bridge2.0-0t64 libatk1.0-0t64 libatspi2.0-0t64 \
    libcairo2 libcups2t64 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0t64 \
    libnspr4 libnss3 libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 \
    libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxrandr2 xvfb \
    fonts-noto-color-emoji fonts-unifont libfontconfig1 libfreetype6 \
    xfonts-scalable fonts-liberation fonts-ipafont-gothic fonts-wqy-zenhei \
    fonts-tlwg-loma-otf fonts-freefont-ttf \
  && rm -rf /var/lib/apt/lists/*

USER vscode
