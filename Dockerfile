# --- Stage 1: Build dependencies using uv ---
FROM python:3.14-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install libpq-dev for PostgreSQL C-extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv directly from the official pre-compiled binary image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uv_bin/uv

# Copy your configuration file
COPY pyproject.toml .

RUN /uv_bin/uv venv /app/.venv && \
    /uv_bin/uv pip install --no-cache -r pyproject.toml


# --- Stage 2: Final Production Runtime ---
FROM python:3.14-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=core.settings

ENV PATH="/app/.venv/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/.venv /app/.venv
COPY . .

RUN useradd -m -u 8888 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8001

CMD ["/app/.venv/bin/python", "-m", "gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8001", "--workers", "3"]