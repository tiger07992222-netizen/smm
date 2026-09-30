FROM node:20-bookworm-slim AS banner-deps
WORKDIR /banner
COPY smm-banner-gen/package.json smm-banner-gen/package-lock.json ./
RUN npm ci --omit=dev

FROM python:3.12-slim-bookworm

COPY --from=node:20-bookworm-slim /usr/local/bin/node /usr/local/bin/node
RUN apt-get update \
    && apt-get install -y --no-install-recommends fontconfig libuuid1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY smm ./smm
COPY config ./config
COPY assets ./assets
COPY scripts ./scripts
COPY smm-banner-gen ./smm-banner-gen
COPY --from=banner-deps /banner/node_modules ./smm-banner-gen/node_modules

ENV PYTHONUNBUFFERED=1
ENV DATA_DIR=/app/data
ENV TZ=Europe/Moscow

VOLUME ["/app/data"]

CMD ["python", "-m", "smm.main", "run"]
