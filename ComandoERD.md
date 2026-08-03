Script DDL generado de manera automatica luego de la digramacion ERD y probado en SQLOnline con MariaDB

CREATE TABLE Moneda
(
  currency_id     INT         NOT NULL AUTO_INCREMENT,
  currency_name   VARCHAR(50) NOT NULL,
  currency_symbol VARCHAR(10) NOT NULL,
  PRIMARY KEY (currency_id)
);

CREATE TABLE Transaccion
(
  transaction_id   INT           NOT NULL AUTO_INCREMENT,
  sender_user_id   INT           NOT NULL,
  receiver_user_id INT           NOT NULL,
  importe          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  transaction_date DATETIME      NULL     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (transaction_id)
);

CREATE TABLE Usuario
(
  user_id            INT           NOT NULL AUTO_INCREMENT,
  currency_id        INT           NOT NULL,
  nombre             VARCHAR(100)  NOT NULL,
  correo_electronico VARCHAR(100)  NOT NULL,
  contraseña         VARCHAR(100)  NOT NULL,
  saldo              DECIMAL(10,2) NULL     DEFAULT 0.00,
  fecha_creacion     DATETIME      NULL     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id)
);

ALTER TABLE Usuario
  ADD CONSTRAINT UQ_correo_electronico UNIQUE (correo_electronico);

ALTER TABLE Usuario
  ADD CONSTRAINT FK_Moneda_TO_Usuario
    FOREIGN KEY (currency_id)
    REFERENCES Moneda (currency_id);

ALTER TABLE Transaccion
  ADD CONSTRAINT FK_Usuario_TO_Transaccion
    FOREIGN KEY (sender_user_id)
    REFERENCES Usuario (user_id);

ALTER TABLE Transaccion
  ADD CONSTRAINT FK_Usuario_TO_Transaccion1
    FOREIGN KEY (receiver_user_id)
    REFERENCES Usuario (user_id);

CREATE UNIQUE INDEX IDX_Usuario
  ON Usuario (user_id ASC);
