#!/bin/bash
set -e

# === 1. Обновление и установка необходимых пакетов ===
echo ">>> Проверка Docker и Docker Compose..."
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Устанавливаем..."
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose-plugin git
fi

# === 2. Клонируем fork проекта ===
echo ">>> Клонируем fork репозитория..."
cd /opt
if [ -d "shvirtd-example-python" ]; then
    echo ">>> Удаляем старую версию проекта..."
    sudo rm -rf shvirtd-example-python
fi

git clone https://github.com/cheytac404/shvirtd-example-python.git
cd shvirtd-example-python

# === 3. Создание .env файла ===
echo ">>> Создаём .env файл..."
cat > .env <<'EOF'
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=example
MYSQL_USER=user
MYSQL_PASSWORD=password
EOF

# === 4. Удаление старых контейнеров и запуск проекта ===
echo ">>> Останавливаем старые контейнеры и удаляем тома..."
sudo docker compose down -v || true

echo ">>> Запускаем проект через Docker Compose..."
cd /opt/shvirtd-example-python
docker compose -f compose.yaml up -d --build

# Ждём, пока контейнеры полностью стартуют
echo ">>> Ждём 10 секунд для запуска контейнеров..."
sleep 10

# === 5. Создание таблицы requests, если её нет ===
echo ">>> Создаём таблицу requests в MySQL, если она не существует..."
sudo docker exec -i mysql_db mysql -uroot -prootpassword <<'SQL'
USE example;
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    time DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(50)
);
SQL

# === 6. Проверка локального сервиса ===
echo ">>> Проверка локального HTTP-сервиса на порту 8090..."
curl -L http://127.0.0.1:8090 || echo "Сервис пока недоступен, проверьте логи контейнеров."

# === 7. Список контейнеров для проверки ===
echo ">>> Список запущенных контейнеров:"
sudo docker ps

echo ">>> Развёртывание завершено!"
echo ">>> Проверьте внешний доступ через: http://<внешний_IP>:8090"