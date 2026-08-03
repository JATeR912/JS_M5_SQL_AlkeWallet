-- ============================================================
-- PROYECTO ALKEWALLET ORGANIZADO
-- ============================================================

---------------------------------------------------------------
-- CREACIÓN DE BASE DE DATOS
---------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS alkewallet;
USE alkewallet;

-- ------------------------------------------------------------
-- 1. CREACIÓN DE ESTRUCTURAS BASE (DDL)
-- ------------------------------------------------------------

-- Tabla Moneda
CREATE TABLE IF NOT EXISTS Moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL
);

-- Tabla Usuario
CREATE TABLE IF NOT EXISTS Usuario (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    contraseña VARCHAR(100) NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00
);

-- Tabla Transaccion
CREATE TABLE IF NOT EXISTS Transaccion (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    receiver_user_id INT NOT NULL,
    importe DECIMAL(10, 2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_user_id) REFERENCES Usuario(user_id),
    FOREIGN KEY (receiver_user_id) REFERENCES Usuario(user_id)
);

-- ------------------------------------------------------------
-- 2. EVOLUCIÓN DDL (Requerimientos Lección 4)
-- ------------------------------------------------------------

-- Asociación de Moneda a Usuario (Default 1 = CLP)
ALTER TABLE Usuario 
ADD COLUMN currency_id INT DEFAULT 1, 
ADD FOREIGN KEY (currency_id) REFERENCES Moneda(currency_id);

-- Inclusión de Fecha de Creación
ALTER TABLE Usuario 
ADD COLUMN fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP;

-- Índice compuesto para optimizar búsquedas
CREATE INDEX idx_usuario_transaccion ON Transaccion(sender_user_id, transaction_date);

-- ------------------------------------------------------------
-- 3. CARGA DE DATOS DE PRUEBA (DML)
-- ------------------------------------------------------------

INSERT INTO Moneda (currency_name, currency_symbol) VALUES
('Peso Chileno', 'CLP'),
('Dólar Estadounidense', 'USD'),
('Euro', 'EUR');

INSERT INTO Usuario (nombre, correo_electronico, contraseña, saldo, currency_id) VALUES
('John Doe', 'john@example.com', 'password123', 5000.00, 1),
('Jane Smith', 'jane@example.com', 'securepass', 10000.00, 2),
('Bob Johnson', 'bob@example.com', 'letmein', 7500.00, 3),    
('Alice Williams', 'alice@example.com', 'secret123', 12000.00, 1),
('Charlie Brown', 'charlie@example.com', 'password456', 8000.00, 1);

INSERT INTO Transaccion (sender_user_id, receiver_user_id, importe) VALUES
(1, 2, 500.00),
(2, 3, 1000.00),
(3, 1, 750.00),
(4, 5, 1200.00),
(1, 4, 800.00);

-- ------------------------------------------------------------
-- 4. MANIPULACIÓN Y CONSULTAS SQL (DQL / DML)
-- ------------------------------------------------------------

-- Actualizar correo electrónico de un usuario específico
UPDATE Usuario 
SET correo_electronico = 'nuevo_correo@example.com' 
WHERE user_id = 2;

-- Eliminar una transacción específica
DELETE FROM Transaccion 
WHERE transaction_id = 5;

-- Consulta: Nombre de la moneda elegida por un usuario específico -> user_id = 1
SELECT u.nombre, m.currency_name, m.currency_symbol
FROM Usuario u
JOIN Moneda m ON u.currency_id = m.currency_id
WHERE u.user_id = 1;

-- Consulta: Todas las transacciones registradas
SELECT * FROM Transaccion;

-- Consulta: Todas las transacciones realizadas por un usuario específico -> sender_user_id = 1
SELECT * FROM Transaccion WHERE sender_user_id = 1;

-- Consulta: Usuarios con saldo mayor a 7500
SELECT nombre, saldo FROM Usuario WHERE saldo > 7500.00;

-- Consulta JOIN: Transacciones con datos de usuario emisor
SELECT u.nombre AS Emisor, t.importe, t.transaction_date
FROM Usuario u
INNER JOIN Transaccion t ON u.user_id = t.sender_user_id;

-- Subconsulta: Usuarios con más de 1 transacción realizada
SELECT u.user_id, u.nombre
FROM Usuario u
WHERE u.user_id IN (
    SELECT sender_user_id 
    FROM Transaccion
    GROUP BY sender_user_id 
    HAVING COUNT(*) > 1
);

-- Insertar una nueva transacción para obtener resultado en sub consulta
-- INSERT INTO Transaccion (sender_user_id, receiver_user_id, importe) VALUES (1, 3, 250.00);

-- Consulta: 5 usuarios con mayor saldo
SELECT nombre, saldo FROM Usuario ORDER BY saldo DESC LIMIT 5;

-- ------------------------------------------------------------
-- 5. DEMOSTRACIÓN DE TRANSACCIONALIDAD (ACID)
-- ------------------------------------------------------------

-- Transacción Exitosa (COMMIT)
START TRANSACTION;
UPDATE Usuario SET saldo = saldo - 500.00 WHERE user_id = 1;
UPDATE Usuario SET saldo = saldo + 500.00 WHERE user_id = 2;
INSERT INTO Transaccion (sender_user_id, receiver_user_id, importe) VALUES (1, 2, 500.00);
COMMIT;

-- Transacción Revertida (ROLLBACK)
START TRANSACTION;
UPDATE Usuario SET saldo = saldo - 15000.00 WHERE user_id = 1;
UPDATE Usuario SET saldo = saldo + 15000.00 WHERE user_id = 2;
ROLLBACK;

-- ------------------------------------------------------------
-- VERIFICACIÓN DE ESTRUCTURAS
-- ------------------------------------------------------------
SHOW TABLES;
DESCRIBE Usuario;
DESCRIBE Moneda;
DESCRIBE Transaccion;