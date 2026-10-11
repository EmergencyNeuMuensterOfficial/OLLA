CREATE TABLE IF NOT EXISTS drp_characters (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    license VARCHAR(64) NOT NULL,
    first_name VARCHAR(24) NOT NULL,
    last_name VARCHAR(24) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('male', 'female') NOT NULL,
    cash INT NOT NULL DEFAULT 500,
    bank INT NOT NULL DEFAULT 2500,
    job_name VARCHAR(50) NOT NULL DEFAULT 'unemployed',
    job_grade INT NOT NULL DEFAULT 0,
    position LONGTEXT NULL,
    metadata LONGTEXT NULL,
    inventory LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_drp_characters_license (license)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS drp_vehicles (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    character_id INT UNSIGNED NOT NULL,
    plate VARCHAR(16) DEFAULT NULL,
    vehicle LONGTEXT NULL,
    trunk LONGTEXT NULL,
    glovebox LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_drp_vehicles_plate (plate),
    KEY idx_drp_vehicles_character (character_id),
    CONSTRAINT fk_drp_vehicles_character
        FOREIGN KEY (character_id) REFERENCES drp_characters(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
