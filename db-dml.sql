INSERT INTO roles (role_name)
VALUES ('Рабочий'),
       ('Мастер'),
       ('Босс');

INSERT INTO worker_shifts (start_time, end_time)
VALUES ('08:30:00', '16:30:00'),
       ('16:30:00', '00:30:00'),
       ('00:30:00', '08:30:00');

INSERT INTO request_types (type_name)
VALUES ('Электрика'),
       ('Инструменты'),
       ('Санитарно-бытовые условия'),
       ('Безопасность труда'),
       ('Документооборот');

INSERT INTO areas (area_name)
VALUES ('Участок #1'),
       ('Участок #2'),
       ('Участок #3'),
       ('Участок #4');

INSERT INTO statuses (status_name)
VALUES ('На рассмотрении'),
       ('Утверждено'),
       ('Отклонена'),
       ('В работе'),
       ('Требует подтверждения'),
       ('Завершена'),
       ('Удалена');

