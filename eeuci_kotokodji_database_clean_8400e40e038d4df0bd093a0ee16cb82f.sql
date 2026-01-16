-- ======================================================
-- Base de données EEUCI - DISTRICT DE KOTOKODJI
-- Schéma de base de données pour la plateforme de gestion
-- ======================================================

-- ======================================================
-- Création de la base de données
-- ======================================================
CREATE DATABASE IF NOT EXISTS eeuci_kotokodji CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Utilisation de la base de données
USE eeuci_kotokodji;

-- ======================================================
-- Table des utilisateurs
-- ======================================================
CREATE TABLE IF NOT EXISTS user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),INDEX(username(100)),
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(150) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    genre VARCHAR(50) NOT NULL UNIQUE,
    grade VARCHAR(50) NOT NULL UNIQUE,
    role ENUM('admin', 'responsable', 'member') DEFAULT 'member',
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);

-- Index pour améliorer les performances
CREATE INDEX id_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ======================================================
-- Table des sessions
-- ======================================================
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(150) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index pour améliorer les performances
CREATE INDEX idx_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);

-- ======================================================
-- Table des actualités et notifications
-- ======================================================
CREATE TABLE IF NOT EXISTS news (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    content TEXT NOT NULL,
    author_id INT NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index pour améliorer les performances
CREATE INDEX idx_news_published ON news(is_published);
CREATE INDEX idx_news_author ON news(author_id);
CREATE INDEX idx_news_created ON news(created_at);

-- ======================================================
-- Table des catégories de documents
-- ======================================================
CREATE TABLE IF NOT EXISTS document_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ======================================================
-- Table des documents
-- ======================================================
CREATE TABLE IF NOT EXISTS documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    mime_type VARCHAR(100),
    category_id INT,
    uploaded_by INT NOT NULL,
    is_public BOOLEAN DEFAULT TRUE,
    download_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES document_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Index pour améliorer les performances
CREATE INDEX idx_documents_category ON documents(category_id);
CREATE INDEX idx_documents_uploader ON documents(uploaded_by);
CREATE INDEX idx_documents_created ON documents(created_at);

-- ======================================================
-- Table des activités
-- ======================================================
CREATE TABLE IF NOT EXISTS activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('en_attente', 'en_cours', 'termine', 'annule') DEFAULT 'en_attente',
    created_by INT NOT NULL,
    assigned_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

-- Index pour améliorer les performances
CREATE INDEX idx_activities_status ON activities(status);
CREATE INDEX idx_activities_creator ON activities(created_by);
CREATE INDEX idx_activities_assigned ON activities(assigned_to);
CREATE INDEX idx_activities_dates ON activities(start_date, end_date);

-- ======================================================
-- Table des audits
-- ======================================================
CREATE TABLE IF NOT EXISTS audits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    activity_id INT,
    audited_by INT NOT NULL,
    status ENUM('en_attente', 'en_cours', 'termine') DEFAULT 'en_attente',
    findings TEXT,
    recommendations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE SET NULL,
    FOREIGN KEY (audited_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Index pour améliorer les performances
CREATE INDEX idx_audits_status ON audits(status);
CREATE INDEX idx_audits_auditor ON audits(audited_by);
CREATE INDEX idx_audits_activity ON audits(activity_id);

-- ======================================================
-- Table des notifications
-- ======================================================
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'warning', 'success', 'error') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index pour améliorer les performances
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at);

-- ======================================================
-- Insertion des catégories par défaut
-- ======================================================
INSERT IGNORE INTO document_categories (name, description) VALUES
('cours', 'Documents de formation et cours'),
('rapports', 'Rapports d\'activités et de gestion'),
('guides', 'Guides et manuels d\'utilisation'),
('archives', 'Documents archivés');

-- ======================================================
-- Insertion des utilisateurs de test
-- ======================================================
INSERT IGNORE INTO users (username, email, password_hash, first_name, last_name, role, email_verified) VALUES
('admin', 'admin@eeuci-kotokodji.org', '$2y$10$example_hash_admin', 'Admin', 'Principal', 'admin', TRUE),
('responsable', 'responsable@eeuci-kotokodji.org', '$2y$10$example_hash_responsable', 'Responsable', 'Activité', 'responsable', TRUE),
('membre1', 'membre1@eeuci-kotokodji.org', '$2y$10$example_hash_membre1', 'Membre', 'Actif', 'member', TRUE);

-- ======================================================
-- Vues utiles
-- ======================================================

-- Vue des utilisateurs actifs
DROP VIEW IF EXISTS active_users;
CREATE VIEW active_users AS
SELECT id, username, email,genre,grade, first_name, last_name, role, created_at, last_login
FROM users
WHERE is_active = TRUE;

-- Vue des documents récents
DROP VIEW IF EXISTS recent_documents;
CREATE VIEW recent_documents AS
SELECT d.id, d.title, d.description, d.created_at, u.username as uploader, dc.name as category
FROM documents d
JOIN users u ON d.uploaded_by = u.id
LEFT JOIN document_categories dc ON d.category_id = dc.id
ORDER BY d.created_at DESC
LIMIT 20;

-- Vue des activités en cours
DROP VIEW IF EXISTS current_activities;
CREATE VIEW current_activities AS
SELECT a.id, a.title, a.description, a.start_date, a.end_date, a.status,
       u1.username as creator, u2.username as assignee
FROM activities a
JOIN users u1 ON a.created_by = u1.id
LEFT JOIN users u2 ON a.assigned_to = u2.id
WHERE a.status IN ('en_cours', 'en_attente')
ORDER BY a.start_date;

-- ======================================================
-- Procédures stockées utiles
-- ======================================================

-- Suppression des procédures existantes
DROP PROCEDURE IF EXISTS CreateUser;
DROP PROCEDURE IF EXISTS AuthenticateUser;
DROP PROCEDURE IF EXISTS UpdateLastLogin;

-- Procédure pour créer un utilisateur
DELIMITER //
CREATE PROCEDURE CreateUser(
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password_hash VARCHAR(255),
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN genre VARCHAR(50),
    IN grade VARCHAR(50) ,
    IN p_role ENUM('admin', 'responsable', 'member')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO users (username, email, password_hash, first_name, last_name,genre,grade, role)
    VALUES (p_username, p_email, p_password_hash, p_first_name, p_last_name,p_genre,p_grade, p_role);
    
    SELECT LAST_INSERT_ID() as user_id;
    
    COMMIT;
END //
DELIMITER ;

-- Procédure pour authentifier un utilisateur
DELIMITER //
CREATE PROCEDURE AuthenticateUser(
    IN p_identifier VARCHAR(100),  -- username ou email
    IN p_password_hash VARCHAR(255)
)
BEGIN
    SELECT id, username, email, first_name, last_name, role, is_active
    FROM users
    WHERE (username = p_identifier OR email = p_identifier)
      AND password_hash = p_password_hash
      AND is_active = TRUE;
END //
DELIMITER ;

-- Procédure pour mettre à jour la dernière connexion
DELIMITER //
CREATE PROCEDURE UpdateLastLogin(
    IN p_user_id INT
)
BEGIN
    UPDATE users
    SET last_login = CURRENT_TIMESTAMP
    WHERE id = p_user_id;
END //
DELIMITER ;

-- ======================================================
-- Déclencheurs (Triggers)
-- ======================================================

-- Suppression du trigger existant
DROP TRIGGER IF EXISTS update_users_timestamp;

-- Trigger pour mettre à jour la date de modification
DELIMITER //
CREATE TRIGGER update_users_timestamp
    BEFORE UPDATE ON users
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //
DELIMITER ;