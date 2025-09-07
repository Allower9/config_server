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
