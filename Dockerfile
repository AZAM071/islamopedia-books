# Builder image for the books. Jupyter Book 2 runs on the MyST engine, whose
# compiled JS ships inside the pip package but needs a Node.js runtime. The
# book theme's app server is started with `node --env-file=...`, which needs
# Node.js >= 20.6, so Debian bookworm's Node.js 18 is not sufficient.
FROM python:3.12-slim-bookworm
WORKDIR /app

# Node.js 22 LTS + npm from NodeSource (the nodejs package bundles npm).
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg procps \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# uv for dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install Python dependencies (Jupyter Book 2) into /app/.venv
COPY pyproject.toml uv.lock /app/
RUN uv sync --frozen --no-dev

# Put the project's virtualenv on PATH so `jupyter book` is available directly.
ENV PATH="/app/.venv/bin:$PATH"
