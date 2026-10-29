#!/usr/bin/env bash

# Доставка статического ресурса на devops-vm
# Использование: scripts/deploy.sh [--dry-run]

set -euo pipefail

REMOTE="devops"
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://devops.local"
CA_CERT="${HOME}/devops.crt"
LOCAL_DIR="$(git rev-parse --show-toplevel)/site/"

DRY_RUN=0
if [[ $# -gt 1 ]]; then
    echo "Использование: $0 [--dry-run]" >&2
    exit 1
elif [[ $# -eq 1 ]]; then
    if [[ "$1" == "--dry-run" ]]; then
        DRY_RUN=1
    else
        echo "Неизвестный аргумент: $1" >&2
        exit 1
    fi
fi

# Проверка наличия главной страницы
if [[ ! -f "${LOCAL_DIR}/index.html" ]]; then
    echo "Ошибка: файл ${LOCAL_DIR}/index.html отсутствует. Доставка отменена." >&2
    exit 1
fi

# Проверка незафиксированных изменений (включая индекс)
if [[ -n "$(git status --porcelain)" ]]; then
    echo "Ошибка: в репозитории есть незафиксированные изменения. Доставка отменена." >&2
    exit 1
fi

# Синхронизация
RSYNC_OPTS=(-avz --delete --chmod=D755,F644)
if [[ $DRY_RUN -eq 1 ]]; then
    RSYNC_OPTS+=(--dry-run)
fi

rsync "${RSYNC_OPTS[@]}" \
    -e "ssh -o BatchMode=yes -o ConnectTimeout=5" \
    "${LOCAL_DIR}" "${REMOTE}:${REMOTE_DIR}"

if [[ $DRY_RUN -eq 1 ]]; then
    echo "Пробный запуск завершён."
    exit 0
fi

# Проверка доступности ресурса с проверкой сертификата
if ! curl -fsS --cacert "${CA_CERT}" "${SITE_URL}" >/dev/null; then
    echo "Ошибка: ресурс ${SITE_URL} недоступен после доставки." >&2
    exit 1
fi

echo "Доставка выполнена успешно. Коммит: $(git rev-parse --short HEAD)"
exit 0
