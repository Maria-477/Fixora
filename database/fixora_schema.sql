-- =========================================================
-- FIXORA DATABASE SCHEMA
-- MySQL Community Server
-- Milestone 3: Database Design
-- =========================================================

CREATE DATABASE IF NOT EXISTS fixora
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE fixora;

-- =========================================================
-- 1. IDENTITY CLUSTER
-- =========================================================

CREATE TABLE users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    phone           VARCHAR(20) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    user_type       ENUM('customer', 'worker', 'admin') NOT NULL,
    preferred_language ENUM('en', 'ur', 'pa') NOT NULL DEFAULT 'en',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE customers (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL UNIQUE,
    full_name       VARCHAR(100) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE workers (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL UNIQUE,
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    is_available    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE worker_profiles (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    worker_id           INT NOT NULL UNIQUE,
    full_name           VARCHAR(100) NOT NULL,
    bio                 TEXT,
    city                VARCHAR(100) NOT NULL,
    experience_years    INT NOT NULL DEFAULT 0,
    profile_image_url   VARCHAR(500),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    INDEX idx_worker_profiles_city (city)
) ENGINE=InnoDB;

-- =========================================================
-- 2. SKILLS & LANGUAGES CLUSTER
-- =========================================================

CREATE TABLE skills (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE worker_skills (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    worker_id       INT NOT NULL,
    skill_id        INT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE,
    UNIQUE KEY uq_worker_skill (worker_id, skill_id)
) ENGINE=InnoDB;

CREATE TABLE languages (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(50) NOT NULL UNIQUE,
    code            VARCHAR(5) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE worker_languages (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    worker_id       INT NOT NULL,
    language_id     INT NOT NULL,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY uq_worker_language (worker_id, language_id)
) ENGINE=InnoDB;

-- =========================================================
-- 3. PORTFOLIO & VERIFICATION CLUSTER
-- =========================================================

CREATE TABLE portfolio_images (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    worker_id       INT NOT NULL,
    image_url       VARCHAR(500) NOT NULL,
    caption         VARCHAR(255),
    uploaded_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE verification (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    worker_id           INT NOT NULL,
    document_type       VARCHAR(50) NOT NULL,
    document_url        VARCHAR(500) NOT NULL,
    status               ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    reviewed_by          INT NULL,
    submitted_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at           TIMESTAMP NULL,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- =========================================================
-- 4. LOCATION & AVAILABILITY CLUSTER
-- =========================================================

CREATE TABLE locations (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    address_line    VARCHAR(255) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    latitude        DECIMAL(10, 8) NOT NULL,
    longitude       DECIMAL(11, 8) NOT NULL,
    is_primary      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_locations_lat_lng (latitude, longitude)
) ENGINE=InnoDB;

CREATE TABLE availability (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    worker_id       INT NOT NULL,
    day_of_week     ENUM('mon','tue','wed','thu','fri','sat','sun') NOT NULL,
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    CHECK (end_time > start_time)
) ENGINE=InnoDB;

-- =========================================================
-- 5. BOOKING CLUSTER
-- =========================================================

CREATE TABLE booking_status (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE bookings (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    customer_id         INT NOT NULL,
    worker_id           INT NOT NULL,
    location_id         INT NOT NULL,
    status_id           INT NOT NULL,
    service_description TEXT,
    scheduled_at        DATETIME NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE RESTRICT,
    FOREIGN KEY (status_id) REFERENCES booking_status(id) ON DELETE RESTRICT,
    INDEX idx_bookings_customer (customer_id),
    INDEX idx_bookings_worker (worker_id),
    INDEX idx_bookings_status (status_id)
) ENGINE=InnoDB;

CREATE TABLE reviews (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    booking_id      INT NOT NULL UNIQUE,
    customer_id     INT NOT NULL,
    worker_id       INT NOT NULL,
    rating          TINYINT NOT NULL,
    comment         TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE chat_messages (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    booking_id      INT NOT NULL,
    sender_id       INT NOT NULL,
    message         TEXT NOT NULL,
    is_read         BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_chat_booking (booking_id)
) ENGINE=InnoDB;

-- =========================================================
-- 6. ENGAGEMENT & MONEY CLUSTER
-- =========================================================

CREATE TABLE notifications (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    title           VARCHAR(150) NOT NULL,
    message         TEXT NOT NULL,
    is_read         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notifications_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE earnings (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    worker_id       INT NOT NULL,
    booking_id      INT NOT NULL UNIQUE,
    amount          DECIMAL(10, 2) NOT NULL,
    earned_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Future-ready: not wired to a real payment gateway yet
CREATE TABLE payments (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    booking_id          INT NOT NULL UNIQUE,
    amount              DECIMAL(10, 2) NOT NULL,
    payment_method      VARCHAR(50),
    status              ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_ref     VARCHAR(255),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- SEED DATA: lookup tables only
-- =========================================================

INSERT INTO booking_status (name) VALUES
    ('pending'), ('confirmed'), ('in_progress'), ('completed'), ('cancelled');

INSERT INTO languages (name, code) VALUES
    ('English', 'en'), ('Urdu', 'ur'), ('Punjabi', 'pa');

INSERT INTO skills (name) VALUES
    ('Plumbing'), ('Electrical'), ('Carpentry'), ('Painting'),
    ('Mechanic'), ('AC Technician'), ('Cleaning');
