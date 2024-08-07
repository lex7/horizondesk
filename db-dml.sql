INSERT INTO roles (role_name)
VALUES ('Рабочий'),
       ('Мастер'),
       ('Начальник'),
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

INSERT INTO specializations (spec_name)
VALUES ('Электрик'),
       ('Механик'),
       ('Завхоз'),
       ('Начальник безопасности'),
       ('Секретарь');

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

-- INSERT INTO users (username, password_hash, surname, name, spec_id, fcm_token, role_id, shift_id)
-- VALUES 
--     ('ivan', 'password123', 'Иван', 'Иванов', 1, NULL, 1, 1),
--     ('vasya', 'password456', 'Василий', 'Васильев', 2, NULL, 2, 1),
--     ('masha', 'password789', 'Мария', 'Мариевна', 3, NULL, 1, 1);

