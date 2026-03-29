# Unicorn't Store — Admin

Panel de administración web para el ecommerce **Unicorn't Store**.  
Permite gestionar el catálogo de productos mediante operaciones CRUD.

Repositorio: **https://github.com/keber/unicornt-store-admin**

---

## Stack

| Capa | Tecnología |
|------|------------|
| Lenguaje | Java 21 |
| Web | Jakarta Servlet 6.0 · JSP 3.1 · JSTL 3.0 |
| Persistencia | JDBC (DAO pattern) |
| Build | Maven 3.x · WAR |
| Servidor | Apache Tomcat 10.1+ |
| BD soportadas | MySQL 8+ · PostgreSQL 15+ (Supabase) |
| UI | Bootstrap 5.3.8 · Font Awesome 6.5.1 |

---

## Requisitos previos

- JDK 21+
- Maven 3.8+
- Apache Tomcat 10.1+
- MySQL 8+ **o** acceso a una instancia PostgreSQL/Supabase

---

## Variables de entorno

Las credenciales **nunca se almacenan en el código fuente**. Deben estar definidas como variables de entorno antes de compilar o al iniciar Tomcat (según el enfoque elegido — ver sección Compilación).

### Perfil `mysql`

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `UNICORNT_MYSQL_URL` | JDBC URL completa | `jdbc:mysql://localhost:3306/unicornt_store?useSSL=false&serverTimezone=America/Santiago&characterEncoding=UTF-8&useUnicode=true` |
| `UNICORNT_MYSQL_ADM_USER` | Usuario de la base de datos | `unicornt-store-admin` |
| `UNICORNT_MYSQL_ADM_PASSWORD` | Contraseña del usuario | `********` |

### Perfil `postgres`

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `UNICORNT_POSTGRES_URL` | JDBC URL completa (Supabase) | `jdbc:postgresql://db.XXXXXXXX.supabase.co:5432/postgres?sslmode=require` |
| `UNICORNT_POSTGRES_ADM_USER` | Usuario de la base de datos | `postgres` |
| `UNICORNT_POSTGRES_ADM_PASSWORD` | Contraseña del usuario | `********` |

#### Definir variables en Windows (sesión actual)

```powershell
$env:UNICORNT_MYSQL_URL             = "jdbc:mysql://localhost:3306/unicornt_store?useSSL=false&serverTimezone=America/Santiago&characterEncoding=UTF-8&useUnicode=true"
$env:UNICORNT_MYSQL_ADM_USER        = "tu_usuario"
$env:UNICORNT_MYSQL_ADM_PASSWORD    = "tu_password"
```

#### Definir variables en Windows (persistente para el usuario)

```powershell
[System.Environment]::SetEnvironmentVariable("UNICORNT_MYSQL_ADM_PASSWORD", "tu_password", "User")
```

---

## Base de datos

Los scripts SQL se encuentran en el repositorio [ecommerce-db-m3](https://github.com/keber/ecommerce-db-m3).

### MySQL

```bash
mysql -u root -p < ecommerce-db-m3/mysql/sql/schema.sql
mysql -u root -p unicornt_store < ecommerce-db-m3/mysql/sql/seed.sql
```

### PostgreSQL / Supabase

```bash
psql -h db.XXXXXXXX.supabase.co -U postgres -f ecommerce-db-m3/postgresql/sql/schema.sql
psql -h db.XXXXXXXX.supabase.co -U postgres -d postgres -f ecommerce-db-m3/postgresql/sql/seed.sql
```

---

## Compilación y empaquetado

El proyecto usa **Maven Profiles** con filtrado de recursos. Las variables de entorno deben estar definidas al momento de ejecutar `mvn package`.

### Perfil MySQL (por defecto)

```bash
mvn package
# equivalente a:
mvn package -P mysql
```

### Perfil PostgreSQL

```bash
mvn package -P postgres
```

El WAR generado se encuentra en:

```
target/unicornt-store-admin.war
```

---

## Despliegue en Tomcat

### Opción A — Copiar el WAR manualmente

```bash
cp target/unicornt-store-admin.war $CATALINA_HOME/webapps/
```

Tomcat desplegará automáticamente la aplicación al detectar el WAR.

### Opción B — Despliegue con Maven (Tomcat Manager)

Agrega el servidor en `~/.m2/settings.xml`:

```xml
<server>
  <id>tomcat-local</id>
  <username>admin</username>
  <password>admin</password>
</server>
```

Luego:

```bash
mvn tomcat7:deploy   -P mysql
# o para redeploy:
mvn tomcat7:redeploy -P mysql
```

---

## Rutas principales

| Método | URL | Descripción |
|--------|-----|-------------|
| `GET` | `/` | Redirige a `/admin/products` |
| `GET` | `/admin/products` | Listado de productos (con búsqueda y filtro por categoría) |
| `GET` | `/admin/products/new` | Formulario de creación |
| `GET` | `/admin/products/edit?id={id}` | Formulario de edición |
| `POST` | `/admin/products` | Crear producto |
| `POST` | `/admin/products/update` | Actualizar producto |
| `POST` | `/admin/products/delete` | Eliminar producto |

---

## Estructura del proyecto

```
unicornt-store-admin/
├── pom.xml                          # Build descriptor con perfiles mysql/postgres
├── src/
│   └── main/
│       ├── java/com/unicornt/store/
│       │   ├── config/
│       │   │   └── DatabaseConnection.java   # Singleton JDBC
│       │   ├── model/
│       │   │   ├── Product.java
│       │   │   ├── Category.java
│       │   │   └── ProductType.java
│       │   ├── dao/
│       │   │   ├── ProductDAO.java
│       │   │   ├── CategoryDAO.java
│       │   │   └── ProductTypeDAO.java
│       │   └── servlet/
│       │       └── AdminProductServlet.java  # Controlador MVC principal
│       ├── resources/
│       │   └── database.properties          # Plantilla filtrada por Maven
│       └── webapp/
│           ├── index.jsp                    # Redirect a /admin/products
│           └── WEB-INF/
│               ├── web.xml
│               └── views/
│                   ├── layout/
│                   │   ├── header.jsp
│                   │   └── footer.jsp
│                   └── admin/
│                       ├── product-list.jsp
│                       └── product-form.jsp
└── target/
    └── unicornt-store-admin.war
```

---

## Proyectos relacionados

| Repositorio | Descripción |
|-------------|-------------|
| [unicornt-store-frontend](https://github.com/keber/unicornt-store-frontend) | Catálogo público (HTML/CSS/JS) |
| [ecommerce-db-m3](https://github.com/keber/ecommerce-db-m3) | Scripts SQL (schema + seed) para MySQL y PostgreSQL |
