#!/bin/bash
set -euo pipefail

LOCAL_REPO_DIR="/Users/bbamkeylee/dev/@project/jindam/jindamhair-backend"
BRANCH="master"

NAS_USER="manage"
NAS_HOST="velysound.synology.me"
NAS_PORT="2022"

UPLOAD_PATH="/tmp/app-upload.jar"
REMOTE_SCRIPT="/volume1/docker/jindamhair-backend/jindam_deploy.sh"

SSH_OPTS="-p ${NAS_PORT} -o StrictHostKeyChecking=accept-new -o PreferredAuthentications=password -o PubkeyAuthentication=no"

echo "🚀 Deploy start (local build -> upload jar -> run NAS jindam_deploy.sh)"
echo ""

echo "📥 (1) Git pull"
cd "${LOCAL_REPO_DIR}"
git fetch --all
git checkout "${BRANCH}"
git pull origin "${BRANCH}"

echo "🔨 (2) Build jar"
./gradlew clean bootJar -x test

JAR_PATH="$(ls -1 build/libs/*.jar | grep -v plain | head -n 1 || true)"
if [[ -z "${JAR_PATH}" ]]; then
  echo "❌ jar not found"
  exit 1
fi
echo "   ✅ built jar: ${JAR_PATH}"

echo ""
echo "📦 (3) Upload jar to NAS via SSH stream -> ${UPLOAD_PATH}"
echo "   (NAS SSH password will be prompted)"
cat "${JAR_PATH}" | ssh ${SSH_OPTS} "${NAS_USER}@${NAS_HOST}" "cat > '${UPLOAD_PATH}'"

echo ""
echo "🐳 (4) Run NAS script: ${REMOTE_SCRIPT} '${UPLOAD_PATH}'"
echo "   (sudo password will be prompted ON NAS)"
ssh -tt ${SSH_OPTS} "${NAS_USER}@${NAS_HOST}" "${REMOTE_SCRIPT} '${UPLOAD_PATH}'"

echo ""
echo "🎉 Deploy finished"
