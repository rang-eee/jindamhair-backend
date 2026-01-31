#!/bin/bash
set -euo pipefail

echo "서버 내에 위치한 shell 스크립트"

LOG_FILE="/volume1/docker/jindamhair-backend/deploy.log"
exec > >(tee -a "$LOG_FILE") 2>&1

NAS_DOCKER_DIR="/volume1/docker/jindamhair-backend"
IMAGE_NAME="my-spring-app"
CONTAINER_NAME="springboot-app"
HOST_PORT="8080"

UPLOAD_PATH="${1:-/tmp/app-upload.jar}"

echo ""
echo "==================== $(date '+%F %T') ===================="
echo "🚀 [NAS] jindam_deploy.sh start"
echo "whoami=$(whoami), pwd=$(pwd), HOME=$HOME"
echo "UPLOAD_PATH=${UPLOAD_PATH}"
echo "=========================================================="
echo ""

# ---- root phase ----
if [[ "${2:-}" == "--as-root" ]]; then
  echo "👑 [ROOT] entered root phase"
  echo "whoami=$(whoami)"
  echo ""

  echo "📁 ensure docker dir"
  mkdir -p "${NAS_DOCKER_DIR}"

  echo "📦 move jar into place"
  ls -la "${UPLOAD_PATH}"
  mv "${UPLOAD_PATH}" "${NAS_DOCKER_DIR}/app.jar"
  chmod 644 "${NAS_DOCKER_DIR}/app.jar"
  ls -la "${NAS_DOCKER_DIR}/app.jar"

  cd "${NAS_DOCKER_DIR}"

  echo "🔨 docker build"
  docker build -t "${IMAGE_NAME}:latest" .

  echo "🛑 remove old container (if any)"
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

  echo "▶️ run new container"
  docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart=always \
    -p "${HOST_PORT}:8080" \
    "${IMAGE_NAME}:latest"

  echo "✅ status"
  docker ps --filter "name=${CONTAINER_NAME}"

  echo ""
  echo "📜 logs (follow 15s then exit)"
  if command -v timeout >/dev/null 2>&1; then
    timeout 15 docker logs -f "${CONTAINER_NAME}" || true
  else
    docker logs -f "${CONTAINER_NAME}" &
    LOG_PID=$!
    sleep 15
    kill "${LOG_PID}" >/dev/null 2>&1 || true
  fi

  echo ""
  echo "🎉 [ROOT] deploy finished"
  exit 0
fi

# ---- manage phase ----
echo "🔎 check uploaded jar"
ls -la "${UPLOAD_PATH}"

echo ""
echo "🔐 sudo auth (you may be prompted once)"
sudo -v

echo ""
echo "🔐 re-run this script as root login shell (sudo -i)"
sudo -i env \
  NAS_DOCKER_DIR="${NAS_DOCKER_DIR}" \
  IMAGE_NAME="${IMAGE_NAME}" \
  CONTAINER_NAME="${CONTAINER_NAME}" \
  HOST_PORT="${HOST_PORT}" \
  UPLOAD_PATH="${UPLOAD_PATH}" \
  bash "$0" "${UPLOAD_PATH}" --as-root

echo ""
echo "🎉 [NAS] jindam_deploy.sh finished"
