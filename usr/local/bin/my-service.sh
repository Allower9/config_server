#!/bin/bash
# Простой сервис который пишет логи
while true; do
    logger -t MY-SERVICE "Service is working at $(date)"
    echo "Log written to syslog"
    sleep 60
done
