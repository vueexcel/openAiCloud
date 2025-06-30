# Stage 1: Build Vue app
FROM node:18 AS frontend
WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install

COPY . .
RUN pnpm run build

# Stage 2: Use OpenCloud image
FROM opencloudeu/opencloud-rolling:latest

COPY ./dev/docker/opencloud/apps.yaml /etc/opencloud/apps.yaml
COPY --from=frontend /app/dist /web/apps/skeleton

ENV OC_URL=http://0.0.0.0:9200 \
    OC_INSECURE=true \
    OC_LOG_LEVEL=error \
    IDM_ADMIN_PASSWORD=admin \
    IDM_CREATE_DEMO_USERS=true \
    PROXY_ENABLE_BASIC_AUTH=true \
    PROXY_TLS=false \
    WEB_ASSET_APPS_PATH=/web/apps

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["opencloud init || true && opencloud server"]
