# Alke Wallet - Base de Datos Relacional
Proyecto desarrollado para el Módulo 5 (Fundamentos de Bases de Datos Relacionales) del programa Talento digital 2026.

---

## Bases de datos
las bases de datos son un conjunto de información organizada bajo un mismo contexto que se almacena para su uso posterior. En el caso de las bases de datos relacionales, la información se estructura en tablas compuestas por filas y columnas, las cuales se conectan entre sí mediante llaves primarias y foráneas.

Entre sus principales ventajas frente a otros modelos destacan:

- **Evita la redundancia:** Al conectar tablas en lugar de duplicar datos, se optimiza el espacio de almacenamiento.
- **Integridad y consistencia de los datos:** Gracias a las reglas y restricciones (como las claves foráneas), se asegura que los datos sean correctos y no queden registros "huérfanos".
- **Consultas flexibles y potentes:** Permite relacionar información de distintas tablas fácilmente utilizando el lenguaje SQL.
- **Seguridad y control de acceso:** Es sencillo gestionar quién tiene permisos para ver o modificar tablas específicas.


## RDBMS LIBRES VS. COMERCIALES

Criterio           | RDBMS Libres (Open Source)           | RDBMS Comerciales (Propietarios)
-------------------|--------------------------------------|--------------------------------------
Ejemplos           | MySQL, PostgreSQL, MariaDB, SQLite  | Oracle Database, Microsoft SQL Server
Licencia / Costo   | Gratuito, código abierto             | De pago (licencias por núcleo/usuario)
Soporte Técnico    | Comunidad, documentación en línea    | Soporte oficial dedicado (SLAs)
Escalabilidad      | Alta, muy usada en web y startups   | Altísima, optimizada para corporativos
Mantenimiento      | A cargo del equipo de desarrollo     | Incluye parches y servicios gestionados

---

## Decisiones de proyecto
Es una base de datos diseñada para transacciones de tipo bancario entre usuarios vinculados a una única moneda, siendo estas tres la tablas principales de la base de datos: **Usuario**, **Moneda** y **Transaccion**.

Se optó por vincular una moneda a cada usuario, estableciendo el peso chileno (CLP) como valor predeterminado. Esto para mantener los estándares actuales de la industria, donde las billeteras virtuales operan con una moneda base por cuenta y gestionan las divisas o importes internacionales mediante cuentas multimoneda o módulos de inversión independientes.

**Evolución del esquema:** Se añadió el campo fecha_creacion a la tabla Usuario mediante un ALTER TABLE para registrar la fecha de alta de los usuarios y mantener la trazabilidad del sistema sin romper la estructura normalizada.

**NORMALIZACION**

Para garantizar la integridad de la información, evitar anomalías al insertar, actualizar o eliminar datos, y eliminar la redundancia en la base de datos de Alke Wallet, se aplicaron las tres reglas de normalización:

1. Primera Forma Normal (1FN) - Atomicidad de los datos:
- Regla: Todos los atributos deben contener valores atómicos (indivisibles) y no deben existir grupos o columnas repetitivas.
- Aplicación en el modelo: 
  * Se definieron campos individuales para datos como 'nombre', 'correo_electronico', 'contraseña', 'saldo', 'importe' y 'transaction_date'.
  * Se aseguró que cada entidad tuviera una Clave Primaria única (user_id, currency_id, transaction_id).

2. Segunda Forma Normal (2FN) - Dependencia funcional completa:
- Regla: Cumplir con la 1FN y garantizar que todos los atributos que no son clave dependan completamente de la Clave Primaria (PK) de su tabla.
- Aplicación en el modelo:
  * Todas las claves primarias definidas en el sistema son simples (de una sola columna), por lo que no existen dependencias parciales. 
  * Atributos como 'nombre' o 'saldo' dependen al 100% únicamente de 'user_id'.

3. Tercera Forma Normal (3FN) - Eliminación de dependencias transitivas:
- Regla: Cumplir con la 2FN y asegurar que ningún atributo no clave dependa de otro atributo no clave (evitar la transitividad).
- Aplicación y cambios realizados en el modelo:
  * Si la información de las monedas (como 'currency_name' o 'currency_symbol') se hubiera guardado directamente en la tabla 'Usuario' o 'Transaccion', esos datos dependerían transitivamente de 'user_id' o 'transaction_id'.
  * Cambio/Separación: Se aisló la entidad 'Moneda' en su propia tabla con su PK (currency_id) y sus propios atributos descriptivos.
  * Se vinculó 'Moneda' con 'Usuario' mediante una clave foránea (currency_id), manteniendo la estructura completamente normalizada en 3FN y protegiendo la consistencia de los datos.

**PROPIEDADES ACID Y MANEJO DE TRANSACCIONES**

1. Propiedades ACID en Alke Wallet:
- **Atomicidad:** Garantiza que una transferencia (descontar saldo a un usuario y sumarlo a otro) se ejecute de forma completa. Si un paso falla, nada se aplica.
- **Consistencia:** Asegura que el saldo total del sistema sea correcto y respete las restricciones definidas antes y después de cada operación.
- **Aislamiento:** Evita que dos transacciones simultáneas sobre la misma cuenta interfieran entre sí antes de confirmarse.
- **Durabilidad:** Garantiza que una vez ejecutado el COMMIT, las operaciones confirmadas permanezcan en la base de datos.

2. Simulación de error e integridad (ROLLBACK):
Se probó un bloque transaccional con START TRANSACTION para simular una transferencia. Ante un error en la operación (saldo negativo) o la necesidad de cancelar el proceso, se ejecutó la sentencia ROLLBACK, revirtiendo exitosamente todos los UPDATE realizados y manteniendo la integridad de los saldos de los usuarios.


## Instrucciones de ejecución:
El script `.sql` del proyecto es compatible con MySQL 8 / MariaDB y puede ejecutarse mediante:

- **Entorno Web:** Copiando el script en la consola de [sqliteonline.com](https://sqliteonline.com) (modo MySQL o MariaDB).
- **Entorno Local / IDE:** Ejecutando `AlkeWallet.sql` en VS Code mediante la extensión **SQLTools** o cualquier cliente MySQL (Workbench, DBeaver).