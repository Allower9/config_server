# config_server
цель - настроить базовую безопаность сервера, настроить логи и их ротацию + скрипты для автоматизации и тп


1) Настройка ssh 
на данном сервере пришлось полностью переустановить ssh
# Полная переустановка
```
sudo apt purge openssh-server -y
sudo apt autoremove -y
sudo apt install openssh-server -y
```
```
# Резервная копия оригинального конфига
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup_original
```

```# Создаем новый минимальный конфиг
sudo vim /etc/ssh/sshd_config
```
редактируем так по шаблону ( см файл )

``` # Полная перезагрузка
sudo systemctl daemon-reload
sudo systemctl restart ssh
sudo ss -lntp | grep ssh
```
2) Rsyslog

3) Logrotate
 Добавляем в /etc/logrotate.d/docker и /etc/logrotate.d/syslog нашу настройку logrotate
``` разбор конфигурации
/var/lib/docker/containers/*/*.log {
    daily              # Ротация каждый день
    rotate 7           # Хранить 7 архивных копий
    compress           # Сжимать старые логи (gzip)
    delaycompress      # Отложить сжатие на один цикл
    missingok          # Не ругаться если файла нет
    copytruncate       # Копировать и обнулять файл
    maxsize 100M       # Ротация при достижении 100MB
    notifempty         # Не ротировать пустые файлы
    dateext            # Добавить дату к имени архива
    dateformat -%Y%m%d-%s  # Формат даты: -ГГГГММДД-секунды
}
```
4) Скрипт + cron
/usr/local/bin/docker-cleanup.sh --- см файл


```добавляем выполение файла (execute)
sudo chmod +x /usr/local/bin/docker-cleanup.sh
```
```заходим в крон 
sudo crontab -e
```
```Добавляем rsyslog + logrotate + script
# Ежедневная ротация логов в 2:00
0 2 * * * /usr/sbin/logrotate /etc/logrotate.conf

# Очистка Docker каждые 6 часов
0 */6 * * * /usr/local/bin/docker-cleanup.sh

# Ежедневная полная очистка в 3:00
0 3 * * * docker system prune -a --volumes --force >> /var/log/docker-system-cleanup.log 2>&1
```
