-- Table: roles
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Table: specializations
CREATE TABLE specializations (
    spec_id SERIAL PRIMARY KEY,
    spec_name VARCHAR(50) NOT NULL UNIQUE
);

-- Table: worker_shifts
CREATE TABLE worker_shifts (
    shift_id SERIAL PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

-- Table: users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    surname VARCHAR(50),
    name VARCHAR(50),
    middle_name VARCHAR(50),
    hire_date DATE,
    phone_number VARCHAR(15),
    birth_date DATE,
    email VARCHAR(100) UNIQUE,
    spec_id INTEGER NOT NULL REFERENCES specializations(spec_id),
    spec_name VARCHAR(50) REFERENCES specializations(spec_name),
    fcm_token VARCHAR(255)[],
    role_id INTEGER NOT NULL REFERENCES roles(role_id),
    shift_id INTEGER REFERENCES worker_shifts(shift_id),
    tokens INTEGER DEFAULT 0,
    num_created INTEGER DEFAULT 0,
    num_completed INTEGER DEFAULT 0,
    last_completed DATE
);

-- Table: request_types
CREATE TABLE request_types (
    request_type SERIAL PRIMARY KEY,
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
    request_type INTEGER NOT NULL REFERENCES request_types(request_type),
    created_by INTEGER NOT NULL REFERENCES users(user_id),
    assigned_to INTEGER REFERENCES users(user_id),
    area_id INTEGER NOT NULL REFERENCES areas(area_id),
    description TEXT NOT NULL,
    status_id INTEGER NOT NULL REFERENCES statuses(status_id),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP,
    deadline TIMESTAMP,
    rejection_reason TEXT
);

-- Table: request_status_log
CREATE TABLE request_status_log (
    log_id SERIAL PRIMARY KEY,
    request_id INTEGER REFERENCES requests(request_id),
    old_status_id INTEGER REFERENCES statuses(status_id),
    new_status_id INTEGER REFERENCES statuses(status_id),
    changed_at TIMESTAMP NOT NULL DEFAULT now(),
    changed_by INTEGER REFERENCES users(user_id),
    rejection_reason TEXT
);
