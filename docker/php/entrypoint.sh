#!/bin/bash

set -e

echo "⏳ Ждём доступность MySQL..."
until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
    sleep 2
done

cd /var/www

# Проверка: установлен ли WordPress
if wp core is-installed --allow-root; then
    echo "✅ WordPress уже установлен"
else
    echo "🚀 Устанавливаем WordPress..."

    # Если wp-config.php ещё не создан — создаём
    if [ ! -f wp-config.php ]; then
        echo "🛠 Создаём wp-config.php..."
        wp config create \
            --dbname="$WORDPRESS_DB_NAME" \
            --dbuser="$WORDPRESS_DB_USER" \
            --dbpass="$WORDPRESS_DB_PASSWORD" \
            --dbhost="$WORDPRESS_DB_HOST" \
            --dbprefix="$WORDPRESS_TABLE_PREFIX" \
            --skip-check \
            --allow-root
    else
        echo "⚠️ wp-config.php уже существует, пропускаем создание"
    fi

    # Устанавливаем WordPress
    wp core install \
        --url="$WP_SITE_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
fi

echo "🟢 WordPress готов"

exec "$@"