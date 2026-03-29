package com.unicornt.store.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Singleton que gestiona la conexion JDBC.
 * Lee configuracion desde src/main/resources/database.properties.
 */
public class DatabaseConnection {

    private static DatabaseConnection instance;

    private String url;
    private String user;
    private String password;
    private String driver;

    private DatabaseConnection() {
        loadProperties();
        loadDriver();
    }

    private void loadProperties() {
        try (InputStream input = getClass()
                .getClassLoader()
                .getResourceAsStream("database.properties")) {

            if (input == null) {
                throw new RuntimeException("No se encontro database.properties en el classpath");
            }

            Properties props = new Properties();
            props.load(input);

            this.url      = props.getProperty("db.url");
            this.user     = props.getProperty("db.user");
            this.password = props.getProperty("db.password");
            this.driver   = props.getProperty("db.driver");

        } catch (IOException e) {
            throw new RuntimeException("Error al cargar database.properties", e);
        }
    }

    private void loadDriver() {
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("No se pudo cargar el driver: " + driver, e);
        }
    }

    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }

    /**
     * Devuelve una nueva conexion JDBC.
     * El llamador es responsable de cerrarla (usar try-with-resources).
     */
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}
