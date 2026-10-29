echo "[4] Веб-сервер"

AUDIT_FAILED=0

check() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf '  [ OK ] %s\n' "$desc"
    else
        printf '  [FAIL] %s\n' "$desc" >&2
        AUDIT_FAILED=1
    fi
}


check "nginx: конфигурация синтаксически корректна" \
    sudo nginx -t

check "nginx: сертификат действителен не менее 30 дней" \
    openssl x509 -checkend $((30*24*3600)) -noout \
    -in /etc/ssl/certs/devops.crt

check "nginx: нет файлов с правом записи для всех" \
    test -z "$(find /var/www/devops-site -perm -o+w -print -quit)"

check "nginx: права ключа равны 600" \
    test "$(sudo stat -c '%a' /etc/ssl/private/devops.key)" = "600"

echo "[5] Контейнеризация"

check "docker: служба активна" \
    test "$(systemctl is-active docker)" = "active"

check "docker: контейнер СУБД healthy" \
    test "$(docker inspect -f '{{.State.Health.Status}}' app-db-1 2>/dev/null)" = "healthy"

check "docker: порты 5000/5432 только на 127.0.0.1" \
    test -z "$(ss -tln | awk 'NR>1 && ($4 ~ /:5000$/ || $4 ~ /:5432$/) && $4 !~ /^127\.0\.0\.1:/')"

check "docker: права .env равны 600" \
    test "$(stat -c '%a' "${HOME}/app/.env" 2>/dev/null)" = "600"

exit "${AUDIT_FAILED}"