# MobileDesk

Мобильное приложение для создания и управления заявками на рабочем месте.

Проект команды 3 
Горизонты-2024. Отборочный этап IT-трека, IT-трек форума Горизонты. Dev++


Инструкция запуска бэка для винды:

git clone https://github.com/lex7/horizondesk.git
cd horizondesk

запускаем docker desktop

запускаем контейнер:
docker compose up --build -d

pip install -r requirements.txt

наполнение базы:
python create_users.py
python create_requests.py
python update_requests.py
python deny_requests.py

открываем порт 8000 в firewall:
Windows Defender Firewall -> advanced settings -> in bound rules -> new rule -> port -> tcp -> 8000 -> allow the connection

далее вводим в cmd команду ipconfig и ищем такое:
Wireless LAN adapter Wi-Fi:

   Connection-specific DNS Suffix  . : beeline
   Link-local IPv6 Address . . . . . : fe80::4f8d:dc70:d4ee:8dba%16
   IPv4 Address. . . . . . . . . . . : 192.168.1.64

  значит бэкенд доступен по адресу, например: http://192.168.1.64:8000/

P.S.

список юзеров в data/users.json

Для работы пушей нужно добавить ключ из firebase accKey.json в корень проекта