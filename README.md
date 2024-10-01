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

все, бэкенд на http://localhost:8000/

список юзеров в data/users.json

Для работы пушей нужно добавить файл accKey.json в корень проекта