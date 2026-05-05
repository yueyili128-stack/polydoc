ARG DEVICE
ARG UV_OVERRIDE

# --- Base images ---
FROM nvidia/cuda:12.6.3-base-ubuntu22.04 AS gpu
ENV UV_ARGUMENTS="--extra all,cu126"
RUN echo "Using GPU image"

FROM ubuntu:22.04 AS cpu
ENV UV_ARGUMENTS="--extra all,cpu"
RUN echo "Using CPU-only image"

# --- Build ---
FROM ${DEVICE:-gpu} AS build
ARG UV_OVERRIDE
ENV UV_ARGUMENTS=${UV_OVERRIDE:-$UV_ARGUMENTS}

ARG USER_UID=1000
ARG USER_GID=1000

# Install system dependencies. Use the default python3 (3.10 on Ubuntu 22.04)
# to keep the image small and avoid PPA-arm64 flakiness. The project supports
# Python >= 3.10, so 3.10 is fine.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      python3 python3-venv python3-pip \
      tzdata nano curl ca-certificates ffmpeg libsm6 libxext6 libnss3 \
      libxi6 libxrandr2 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxrender1 \
      libasound2 libatk1.0-0 libgtk-3-0 libreoffice libjpeg-dev libpango-1.0-0 \
      libpangoft2-1.0-0 weasyprint && \
    ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid ${USER_GID} polydocuser \
 && useradd --uid ${USER_UID} --gid ${USER_GID} -m polydocuser

WORKDIR /app
RUN chown polydocuser:polydocuser /app
USER polydocuser

# Set up Python virtual environment using the default python3 (3.10 on 22.04)
RUN python3 -m venv .venv \
 && .venv/bin/pip install --no-cache-dir uv

# Install dependencies (cached unless pyproject.toml / uv.lock changes).
# Drop --frozen so uv can re-resolve inside the container if the local lock
# was generated under a slightly different Python/platform; the image is still
# reproducible because pyproject.toml pins the constraints.
COPY --chown=polydocuser:polydocuser pyproject.toml uv.lock /app/
RUN .venv/bin/uv sync --no-install-project ${UV_ARGUMENTS}

# Install polydoc from local source code
COPY --chown=polydocuser:polydocuser . /app
RUN .venv/bin/uv pip install --no-cache --no-deps -e .

# --- Runtime ---
ENV PATH="/app/.venv/bin:$PATH"
ENV DASK_DISTRIBUTED__WORKER__DAEMON=False

ENTRYPOINT ["/bin/bash"]
