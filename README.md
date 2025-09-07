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
```Создадим простой файл-скрипт для примера  - /usr/local/bin/my-service.sh ( см файлы )
sudo chmod +x /usr/local/bin/my-service.sh
```
```Создаём файл в rsyslog
sudo vim /etc/rsyslog.d/my-service.conf
```
```Теперь будем перенаправлять логи
# Перенаправляем логи с тегом MY-SERVICE в отдельный файл
:programname, isequal, "MY-SERVICE" /var/log/my-service.log
& stop
```
```Перезапускаем
sudo systemctl restart rsyslog
```


4) Logrotate
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
```также добавим наш скрипт для примера добавим my-service.sh 
sudo vim /etc/logrotate.d/my-service
```
вставляем 
```/var/log/my-service.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
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
5) Unit для my-service.sh
```Создаём юнит
sudo vim /etc/systemd/system/my-service.service
```
```Код
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/my-service.sh
Restart=always
RestartSec=10
User=root

# Настройки логирования
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=MY-SERVICE

[Install]
WantedBy=multi-user.target
```

```После перезагрузим, поставим в автозагрузку и стартанём его ( юнит)

sudo systemctl daemon-reload
sudo systemctl enable my-service
sudo systemctl start my-service
```
```Проверка
# Статус сервиса
sudo systemctl status my-service

# Логи сервиса
sudo tail -f /var/log/my-service.log

# Все системные логи с нашим тегом
sudo journalctl -t MY-SERVICE
```


Команды для просмотра
```
# Поиск по определенному тегу (если настроили MY-SERVICE)
sudo tail -f /var/log/syslog | grep MY-SERVICE

# Если создали отдельный лог для сервиса
sudo tail -f /var/log/my-service.log
#
sudo tail -n 5 /var/log/syslog


# Посмотреть когда последний раз запускался logrotate
sudo cat /var/lib/logrotate/status

# Посмотреть историю выполнения
sudo grep logrotate /var/log/syslog | tail -10

# Проверить конфиг на ошибки
sudo logrotate -d /etc/logrotate.d/docker
```

