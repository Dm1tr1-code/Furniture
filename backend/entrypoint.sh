#!/bin/bash
set -e

echo "Ожидание доступности PostgreSQL..."
# Ждем пока база данных станет доступной - используем более универсальный подход
MAX_RETRIES=30
RETRY_COUNT=0

until [ $RETRY_COUNT -eq $MAX_RETRIES ] || pg_isready -h db -U postgres -d furniture_marketplace; do
  echo "PostgreSQL недоступен - ожидание... ($((RETRY_COUNT+1))/$MAX_RETRIES)"
  RETRY_COUNT=$((RETRY_COUNT+1))
  sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  echo "Не удалось подключиться к PostgreSQL после $MAX_RETRIES попыток. Выход."
  exit 1
fi

echo "PostgreSQL доступен!"

echo "Запуск миграций Prisma..."
npx prisma migrate deploy

echo "Генерация Prisma клиента..."
npx prisma generate

echo "Запуск FastAPI приложения..."
uvicorn main:app --host 0.0.0.0 --port 8000
