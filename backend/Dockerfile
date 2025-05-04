FROM python:3.11-slim

WORKDIR /app

# Установка необходимых системных зависимостей
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev curl postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Установка Node.js для Prisma CLI
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g prisma

# Копирование файлов зависимостей
COPY requirements.txt .

# Установка зависимостей Python
RUN pip install --no-cache-dir -r requirements.txt

# Копирование entrypoint.sh и настройка прав
COPY entrypoint.sh .
RUN chmod +x /app/entrypoint.sh

# Копирование исходного кода
COPY . .

# Генерация Prisma-клиента
RUN prisma generate

# Создание скрипта для запуска миграций и сервера
RUN echo '#!/bin/bash\n\
echo "Запуск миграций Prisma..."\n\
prisma migrate deploy\n\
echo "Миграции выполнены успешно, запуск сервера..."\n\
exec uvicorn main:app --host 0.0.0.0 --port 8000\n\
' > /app/start.sh && chmod +x /app/start.sh

# Проверка здоровья приложения
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8000/ || exit 1

# Открываем порт для приложения
EXPOSE 8000

# Запуск приложения через entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

