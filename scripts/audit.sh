echo "[4] Веб-сервер"

# б) конфигурация nginx синтаксически корректна
check "nginx: конфигурация синтаксически корректна" \
    sudo nginx -t

# в) сертификат истекает не ранее чем через 30 дней
check "nginx: сертификат действителен не менее 30 дней" \
    openssl x509 -checkend $((30*24*3600)) -noout \
    -in /etc/ssl/certs/devops.crt

# г1) в каталоге ресурса нет файлов, доступных для записи всем
check "nginx: нет файлов с правом записи для всех" \
    test -z "$(find /var/www/devops-site -perm -o+w -print -quit)"

# г2) права закрытого ключа равны 600
check "nginx: права ключа равны 600" \
    test "$(sudo stat -c '%a' /etc/ssl/private/devops.key)" = "600"
