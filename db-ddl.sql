-- Table: positions
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE
);

-- Table: worker_shifts
CREATE TABLE worker_shifts (
    shift_id SERIAL PRIMARY KEY,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL
);

-- Table: users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    surname VARCHAR(50),
    name VARCHAR(50),
    specialization VARCHAR(100),
    fcm_token VARCHAR(255),
    position_id INTEGER REFERENCES positions(position_id),
    shift_id INTEGER REFERENCES worker_shifts(shift_id)
);

-- Table: request_types
CREATE TABLE request_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- Table: areas
CREATE TABLE areas (
    area_id SERIAL PRIMARY KEY,
    area_name VARCHAR(50) NOT NULL UNIQUE
);

-- Table: statuses
CREATE TABLE statuses (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

-- Table: requests
CREATE TABLE requests (
    request_id SERIAL PRIMARY KEY,
    request_type INTEGER REFERENCES request_types(type_id),
    created_by INTEGER REFERENCES users(user_id),
    assigned_to INTEGER REFERENCES users(user_id),
    area_id INTEGER REFERENCES areas(area_id),
    description TEXT NOT NULL,
    status_id INTEGER REFERENCES statuses(status_id),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now(),
    deadline TIMESTAMP NOT NULL
);

-- Table: request_status_log
CREATE TABLE request_status_log (
    log_id SERIAL PRIMARY KEY,
    request_id INTEGER REFERENCES requests(request_id),
    old_status_id INTEGER REFERENCES statuses(status_id),
    new_status_id INTEGER REFERENCES statuses(status_id),
    changed_at TIMESTAMP NOT NULL DEFAULT now(),
    changed_by INTEGER REFERENCES users(user_id)
);
