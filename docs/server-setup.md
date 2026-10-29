## 8. Веб-сервер

- **Устанавливаемый пакет:** `nginx`.
- **Путь к конфигурации ресурса:** `/etc/nginx/sites-available/devops-site`.
- **Каталог ресурса, владелец, права:** `/var/www/devops-site`, `devops:devops`, каталоги `755`, файлы `644`.
- **Сертификат:** `/etc/ssl/certs/devops.crt`, `root:root`, `644`.
- **Ключ:** `/etc/ssl/private/devops.key`, `root:root`, `600`.
- **Срок действия сертификата:** 365 дней.
- **Команда формирования сертификата:**

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/devops.key \
  -out /etc/ssl/certs/devops.crt \
  -subj "/CN=devops.local" \
  -addext "subjectAltName=DNS:devops.local"
```
## 9. Контейнеризация

- **Способ установки Docker Engine:** официальный репозиторий Docker.
- **Участники группы `docker`:** `devops`.
- **Расположение проекта на сервере:** `/home/devops/app`.
- **Расположение файла `.env` и права:** `/home/devops/app/.env`, права `600`.
- **Публикуемые порты и адреса:** `127.0.0.1:5000:5000` (приложение); `80`, `443` (Nginx).
- **Именованные тома:** `app_db_data` → `/var/lib/postgresql/data`.

**Конфигурация обратного прокси-сервера**:
```nginx
location /app/ {
    proxy_pass http://127.0.0.1:5000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```