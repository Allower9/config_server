#!/bin/bash

# Логирование
LOG_FILE="/var/log/docker-cleanup.log"

# Функция логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Очистка неиспользуемых образов старше 24 часов
clean_old_images() {
    log "Starting Docker image cleanup..."
    
    # Удаляем образы старше 24 часов
    docker image prune -a --filter "until=24h" --force
    
    # Удаляем остановленные контейнеры старше 24 часов
    docker container prune --filter "until=24h" --force
    
    # Удаляем висячие образы (dangling)
    docker image prune --force
    
    # Удаляем неиспользуемые volumes
    docker volume prune --force
    
    # Удаляем неиспользуемые сети
    docker network prune --force
    
    log "Docker cleanup completed"
}

# Проверяем, установлен ли Docker
if ! command -v docker &> /dev/null; then
    log "ERROR: Docker is not installed"
    exit 1
fi

# Проверяем, запущен ли Docker daemon
if ! docker info >/dev/null 2>&1; then
    log "ERROR: Docker daemon is not running"
    exit 1
fi

clean_old_images
